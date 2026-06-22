import logging
from fastapi import FastAPI, Query, HTTPException
from fastapi.responses import StreamingResponse
import qrcode
import io
import zlib

# Setup logging to a file
logging.basicConfig(
    filename="/app/requests.log", 
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

app = FastAPI()

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/generate")
def generate_qr(data: str = Query(..., description="The main text or payload data")):
    if not data:
        raise HTTPException(status_code=400, detail="Data parameter cannot be empty")
    
    try:
        # 1. Calculate CRC32 checksum of the incoming data string
        # We encode to bytes first, compute CRC, and convert to a hex string
        crc_value = zlib.crc32(data.encode('utf-8'))
        crc_hex = f"{crc_value:08X}" 
        
        # 2. Append CRC to your data payload 
        # (Modify this format depending on how your scanner expects to parse it)
        payload_with_crc = f"{data}|CRC:{crc_hex}"
        
        logging.info(f"Generating QR. Data len: {len(data)}, CRC: {crc_hex}")
        
        # 3. Optimize QR for high-density data
        qr = qrcode.QRCode(
            version=None,                           # None auto-sizes the grid based on data volume
            error_correction=qrcode.constants.ERROR_CORRECT_M, # 'M' (15%) or 'Q' (25%) is ideal for dense data
            box_size=6,                             # Smaller box size keeps the overall image size reasonable
            border=4
        )
        
        qr.add_data(payload_with_crc)
        qr.make(fit=True)
        
        # Build the PNG
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Save image to bytes buffer in memory
        buf = io.BytesIO()
        img.save(buf, format="PNG")
        buf.seek(0)
        
        return StreamingResponse(buf, media_type="image/png")
        
    except Exception as e:
        logging.error(f"Error generating dense QR code: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")