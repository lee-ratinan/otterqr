import io
import logging
import os
import re
from datetime import datetime
from typing import Literal, Optional

import qrcode
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field, field_validator, model_validator


# --- Advanced Daily File Logger ---
class DailyFileHandler(logging.Handler):
    """Custom logging handler that dynamically creates file paths based on the current date."""
    def __init__(self, log_dir="/app/logs"):
        super().__init__()
        self.log_dir = log_dir
        os.makedirs(self.log_dir, exist_ok=True)

    def emit(self, record):
        try:
            log_date = datetime.now().strftime("%Y-%m-%d")
            log_file = os.path.join(self.log_dir, f"log-{log_date}.log")

            # Open file manually to adapt to daily changes on the fly
            with open(log_file, "a", encoding="utf-8") as f:
                f.write(self.format(record) + "\n")
        except Exception:
            self.handleError(record)

# Setup Logging
logger = logging.getLogger("otterqr")
logger.setLevel(logging.INFO)
log_formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
daily_handler = DailyFileHandler()
daily_handler.setFormatter(log_formatter)
logger.addHandler(daily_handler)


# --- FastAPI & App Config ---
app = FastAPI(title="OtterQR Core API Engine")

# --- Helper Functions for EMVCo TLV Format ---
def create_tlv(tag: str, value: str) -> str:
    """Helper to cleanly stitch EMVCo standard Type-Length-Value format."""
    if not value:
        return ""
    length = f"{len(value):02d}"
    return f"{tag}{length}{value}"

def calculate_crc16(data: str) -> str:
    """Calculates standard EMVCo CRC-16/CCITT-FALSE (Poly: 0x1021, Init: 0xFFFF)"""
    crc = 0xFFFF
    for byte in data.encode('utf-8'):
        crc ^= (byte << 8)
        for _ in range(8):
            if crc & 0x8000:
                crc = (crc << 1) ^ 0x1021
            else:
                crc = crc << 1
            crc &= 0xFFFF
    return f"{crc:04X}"


# --- Strict Pydantic Data Contract Validations ---
class QRRequest(BaseModel):
    country: Literal['TH'] = Field(..., description="Currently only 'TH' is supported")
    type: Literal['static', 'dynamic'] = Field(...)
    mode: Literal['phone', 'bill'] = Field(...)

    # Mode-dependent optional values
    phone_number: Optional[str] = Field(None, alias="phone", description="Format: +66XXXXXXXXX")
    bill_id: Optional[str] = Field(None, max_length=15, description="15-character Bill ID")
    ref1: Optional[str] = Field(None, max_length=20)
    ref2: Optional[str] = Field(None, max_length=20)

    # Conditional Values
    amount: Optional[float] = Field(None, description="Required only for 'dynamic' profiles")
    merchant_name: str = Field(..., max_length=25)
    city: str = Field(..., max_length=60)
    postal_code: str = Field(..., description="5-digit exact pattern for Thailand")

    @field_validator('phone_number')
    @classmethod
    def validate_thai_phone(cls, v):
        if v is not None:
            if not re.match(r"^\+66\d{9}$", v):
                raise ValueError("Phone number must match international Thai format: +66XXXXXXXXX")
        return v

    @field_validator('postal_code')
    @classmethod
    def validate_postal(cls, v, info):
        # Strict validation handling for TH expansion rule
        if info.data.get('country') == 'TH' and not re.match(r"^\d{5}$", v):
            raise ValueError("Thailand postal code must be exactly 5 numeric digits")
        return v

    @model_validator(mode='after')
    def validate_mode_dependencies(self) -> 'QRRequest':
        # Check Mode: Phone requirements
        if self.mode == 'phone' and not self.phone_number:
            raise ValueError("Field 'phone' (+66XXXXXXXXX) is required when mode is set to 'phone'")

        # Check Mode: Bill requirements
        if self.mode == 'bill':
            if not self.bill_id or len(self.bill_id) != 15 or not self.bill_id.isdigit():
                raise ValueError("Field 'bill_id' must be provided and contain exactly 15 numeric digits")
            if not self.ref1:
                raise ValueError("Field 'ref1' is required for bill payments")

        # Check Conditional Matrix: Amount rules
        if self.type == 'dynamic' and (self.amount is None or self.amount <= 0):
            raise ValueError("Amount is required and must be greater than 0 for 'dynamic' type profiles")
        if self.type == 'static' and self.amount is not None:
            raise ValueError("Static codes must not specify an amount value")

        return self


# --- Main Application Endpoints ---
@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.post("/generate")
def generate_promptpay_qr(payload: QRRequest):
    logger.info(f"Received QR generation request: Type={payload.type}, Mode={payload.mode}")
    try:
        # Step 1: Base Application Profiles
        raw_emvco = ""
        raw_emvco += create_tlv("00", "01") # Payload Format Indicator
        raw_emvco += create_tlv("01", "11" if payload.type == "static" else "12") # Point of Initiation

        # Step 2: Merchant Account Info Strategy Execution Block
        if payload.mode == "phone":
            # Strip '+66' and replace with leading padded '0066'
            cleaned_phone = "0066" + payload.phone_number[3:]
            # Tag 29 sub-tags: 00 = AID Application Identifier, 01 = Phone data
            tag29_value = create_tlv("00", "A000000677010111") + create_tlv("01", cleaned_phone)
            raw_emvco += create_tlv("29", tag29_value)

        elif payload.mode == "bill":
            # Tag 30 sub-tags: 00 = Domestic AID, 01 = Merchant Bill ID, 02 = Ref1, 03 = Ref2 (if available)
            tag30_value = (
                create_tlv("00", "A000000677010112") +
                create_tlv("01", payload.bill_id) +
                create_tlv("02", payload.ref1)
            )
            if payload.ref2:
                tag30_value += create_tlv("03", payload.ref2)

            raw_emvco += create_tlv("30", tag30_value)

        # Step 3: Base Meta Values Mapping Block
        raw_emvco += create_tlv("53", "764") # ISO Currency Code for THB (Always 764)

        if payload.type == "dynamic" and payload.amount is not None:
            # Format to exactly two decimal places for EMVCo standard compatibility
            amount_str = f"{payload.amount:.2f}"
            raw_emvco += create_tlv("54", amount_str)

        raw_emvco += create_tlv("58", payload.country)
        raw_emvco += create_tlv("59", payload.merchant_name)
        raw_emvco += create_tlv("60", payload.city)
        raw_emvco += create_tlv("61", payload.postal_code)

        # Step 4: CRC Append Frame Preparation
        raw_emvco += "6304"

        # Calculate matching CRC-16 and concatenate final string
        final_crc = calculate_crc16(raw_emvco)
        final_qr_string = raw_emvco + final_crc

        logger.info(f"Successfully generated payload structure. Raw string: {final_qr_string}")

        # Step 5: High Density Stream Output Generation
        qr = qrcode.QRCode(
            version=None,
            error_correction=qrcode.constants.ERROR_CORRECT_M,
            box_size=6,
            border=4
        )
        qr.add_data(final_qr_string)
        qr.make(fit=True)

        img = qr.make_image(fill_color="black", back_color="white")

        buf = io.BytesIO()
        img.save(buf, format="PNG")
        buf.seek(0)

        return StreamingResponse(buf, media_type="image/png")

    except Exception as e:
        logger.error(f"Catastrophic payload conversion system exception: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal processing error occurred.")