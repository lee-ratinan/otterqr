<?php

namespace App\Controllers;

use CodeIgniter\HTTP\ResponseInterface;
use Endroid\QrCode\Color\Color;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\Label\Label;
use Endroid\QrCode\Logo\Logo;
use Endroid\QrCode\RoundBlockSizeMode;
use Exception;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;

class Home extends BaseController
{

    // TAGS
    const TAG_PFI = 0;
    const TAG_POI = 1;
    const TAG_PROMPTPAY_ID = 29;
    const TAG_PROMPTPAY_BILL_PAYMENT = 30;
    const SUBTAG_PROMPTPAY_AID = 0; // BOTH 29/30
    const SUBTAG_PROMPTPAY_PHONE_NUMBER = 1; // ONLY 29
    const SUBTAG_PROMPTPAY_BILLER_ID = 1; // ONLY 30
    const SUBTAG_PROMPTPAY_REF_1 = 2; // ONLY 30
    const SUBTAG_PROMPTPAY_REF_2 = 3; // ONLY 30
    const TAG_CURRENCY_CODE = 53;
    const TAG_TRANSACTION_AMOUNT = 54;
    const TAG_COUNTRY_CODE = 58;
    const TAG_MERCHANT_NAME = 59;
    const TAG_MERCHANT_CITY = 60;
    const TAG_POSTAL_CODE = 61;
    const TAG_CRC = 63;
    // COUNTRY CODE
    const COUNTRY_CODE_TH = 'TH';
    // PAYLOAD FORMAT INDICATOR
    const PFI_STANDARD_VAL = '01';
    // POINT OF INITIATION
    const POI_STATIC = 'STATIC';
    const POI_STATIC_VAL = '11';
    const POI_DYNAMIC = 'DYNAMIC';
    const POI_DYNAMIC_VAL = '12';
    // MERCHANT ACCOUNT INFORMATION
    const MAI_PROMPTPAY_ID = 'PROMPTPAY_ID';
    const MAI_BILL_PAYMENT = 'BILL_PAYMENT';
    // AID
    const AID_MERCHANT_PROMPTPAY_ID  = 'A000000677010111';
    const AID_MERCHANT_BILL_DOMESTIC = 'A000000677010112';
    // CURRENCY CODE
    const CURRENCY_CODE_THB = '764';
    // COLORS
    private array $promptpayColor = [0, 58, 109];

    public function index(): string
    {
        $data = [
            'readmePath' => ROOTPATH . 'README.md'
        ];
        return view('readme', $data);
    }

    // GENERATOR ////////////////////////////////////////////////////////////////

    /**
     * Generate QR Code
     * @param string $qrData
     * @param string $countryCode
     * @param array $color
     * @return ResponseInterface
     */
    private function generateQrCode(string $qrData, string $countryCode = '', array $color = []): ResponseInterface
    {
        $writer = new PngWriter();
        if (empty($color)) {
            $color = [0, 0, 0];
        }
        // Create QR code
        $qrCode = new QrCode(
            data: $qrData,
            encoding: new Encoding('UTF-8'),
            errorCorrectionLevel: ErrorCorrectionLevel::Low,
            size: 300,
            margin: 10,
            roundBlockSizeMode: RoundBlockSizeMode::Margin,
            foregroundColor: new Color($color[0], $color[1], $color[2]),
            backgroundColor: new Color(255, 255, 255)
        );
        // Create generic logo
        $logo     = null;
        $fileDirs = [
            'TH' => dirname(__DIR__, 2) . '/public/PromptPay.png'
        ];
        if (!empty($countryCode) && isset($fileDirs[$countryCode])) {
            $filePath = $fileDirs[$countryCode];
            $logo = new Logo(
                path: $filePath,
                resizeToWidth: 80,
                punchoutBackground: true
            );
        }
        $result = $writer->write($qrCode, $logo);
        $png    = $result->getString();
        return $this->response
            ->setHeader('Content-Type', 'image/png')
            ->setHeader('Content-Length', strlen($png))
            ->setBody($png);
    }

    /**
     * Generates the EMVCo Tag 63 CRC16 value and appends it to the payload.
     * @param string $payload The initial EMVCo string (without Tag 63).
     * @param bool $returnOnlyCrc If true, only the CRC value is returned.
     * @return string The final payload with "6304" and the 4-digit hex checksum.
     */
    function appendEmvcoCrc(string $payload, bool $returnOnlyCrc = false): string
    {
        // 1. Append the CRC Tag ID (63) and Length (04) to the string before calculating
        $strToCalculate = $payload . self::TAG_CRC . "04";
        // 2. Initialize CRC-16/CCITT-FALSE parameters
        $crc = 0xFFFF;        // Initial value
        $polynomial = 0x1021; // Polynomial x^16 + x^12 + x^5 + 1
        // 3. Process each byte in the string
        $length = strlen($strToCalculate);
        for ($i = 0; $i < $length; $i++) {
            $ascii = ord($strToCalculate[$i]);
            $crc ^= ($ascii << 8);
            for ($j = 0; $j < 8; $j++) {
                if ($crc & 0x8000) {
                    $crc = ($crc << 1) ^ $polynomial;
                } else {
                    $crc <<= 1;
                }
                // Keep it 16-bit
                $crc &= 0xFFFF;
            }
        }
        // 4. Format to uppercase, 4-digit hex string padded with zeros
        $crcHex = sprintf('%04X', $crc);
        if ($returnOnlyCrc) {
            return $crcHex;
        }
        return $strToCalculate . $crcHex;
    }

    /**
     * Format individual tag
     * @param string|int $tagId
     * @param string $value
     * @return string
     */
    private function formatTag(string|int $tagId, string $value): string
    {
        $tagId  = str_pad($tagId, 2, '0', STR_PAD_LEFT);
        $length = strlen($value);
        return $tagId . str_pad($length, 2, '0', STR_PAD_LEFT) . $value;
    }

    /**
     * Generate PromptPay QR Code for Thailand
     * @throws Exception
     */
    private function generatePromptPayQr(): ResponseInterface
    {
        // PAYLOAD FORMAT INDICATOR
        $qrString = $this->formatTag(self::TAG_PFI, self::PFI_STANDARD_VAL);
        // POINT OF INITIATION
        $pointOfInit = $this->request->getPost('pointOfInitiation');
        $pointOfInit = strtoupper($pointOfInit);
        if (!in_array($pointOfInit, [self::POI_STATIC, self::POI_DYNAMIC])) {
            throw new Exception('Point of initiation not supported');
        }
        $pointOfInitValue = ($pointOfInit == self::POI_STATIC ? self::POI_STATIC_VAL : self::POI_DYNAMIC_VAL);
        $qrString .= $this->formatTag(self::TAG_POI, $pointOfInitValue);
        // MERCHANT ACCOUNT INFORMATION
        $merchantAccountInformation = $this->request->getPost('merchantAccountInformation');
        $merchantAccountInformation = strtoupper($merchantAccountInformation);
        if (!in_array($merchantAccountInformation, [self::MAI_PROMPTPAY_ID, self::MAI_BILL_PAYMENT])) {
            throw new Exception('Merchant account information not supported');
        }
        if ($merchantAccountInformation == self::MAI_PROMPTPAY_ID) {
            // PROMPTPAY ID
            $phoneNumber = $this->request->getPost('phoneNumber');
            $phoneNumber = str_replace(['+', ' ', '-'], '', $phoneNumber);
            if (!preg_match('/^66\d{9}$/', $phoneNumber)) {
                throw new Exception('Invalid phone number');
            }
            $phoneNumber = '00' . str_replace('+', '', $phoneNumber);
            $subtagStr   = $this->formatTag(self::SUBTAG_PROMPTPAY_AID, self::AID_MERCHANT_PROMPTPAY_ID);
            $subtagStr  .= $this->formatTag(self::SUBTAG_PROMPTPAY_PHONE_NUMBER, $phoneNumber);
            $qrString   .= $this->formatTag(self::TAG_PROMPTPAY_ID, $subtagStr);
        } else {
            // BILL PAYMENT
            if (self::POI_STATIC == $pointOfInit) {
                throw new Exception('Bill payment not supported for static point of initiation');
            }
            $billerId = $this->request->getPost('billerId');
            if (!preg_match('/^\d{15}$/', $billerId)) {
                // Biller ID = Tax ID + suffix, which is 15 digits
                throw new Exception('Invalid biller ID');
            }
            $subtagStr  = $this->formatTag(self::SUBTAG_PROMPTPAY_AID, self::AID_MERCHANT_BILL_DOMESTIC);
            $subtagStr .= $this->formatTag(self::SUBTAG_PROMPTPAY_BILLER_ID, $billerId);
            // REF1
            $ref1  = $this->request->getPost('ref1');
            if (!preg_match('/[A-Za-z0-9]{1,20}/', $ref1)) {
                throw new Exception('Invalid reference 1');
            }
            $subtagStr .= $this->formatTag(self::SUBTAG_PROMPTPAY_REF_1, $ref1);
            $ref2  = $this->request->getPost('ref2');
            if (!empty($ref2)) {
                if (!preg_match('/[A-Za-z0-9]{1,20}/', $ref2)) {
                    throw new Exception('Invalid reference 2');
                }
                $subtagStr .= $this->formatTag(self::SUBTAG_PROMPTPAY_REF_2, $ref2);
            }
            $qrString .= $this->formatTag(self::TAG_PROMPTPAY_BILL_PAYMENT, $subtagStr);
        }
        // CURRENCY CODE
        $qrString .= $this->formatTag(self::TAG_CURRENCY_CODE, self::CURRENCY_CODE_THB);
        // TRANSACTION AMOUNT
        if (self::POI_DYNAMIC == $pointOfInit) {
            $amount = $this->request->getPost('transactionAmount');
            if (!preg_match('/^\d+(\.\d{2})?$/', $amount)) {
                throw new Exception('Invalid transaction amount');
            } else if (13 < strlen($amount)) {
                throw new Exception('Transaction amount too long');
            }
            $qrString .= $this->formatTag(self::TAG_TRANSACTION_AMOUNT, $amount);
        }
        // COUNTRY CODE
        $qrString .= $this->formatTag(self::TAG_COUNTRY_CODE, self::COUNTRY_CODE_TH);
        // MERCHANT NAME
        $merchantName = $this->request->getPost('merchantName');
        if (!preg_match('/^[A-Za-z0-9]{1,25}$/', $merchantName)) {
            throw new Exception('Invalid merchant name');
        }
        $qrString .= $this->formatTag(self::TAG_MERCHANT_NAME, $merchantName);
        // MERCHANT CITY
        $merchantCity = $this->request->getPost('merchantCity');
        if (!preg_match('/^[A-Za-z0-9]{1,15}$/', $merchantCity)) {
            throw new Exception('Invalid merchant city');
        }
        $qrString .= $this->formatTag(self::TAG_MERCHANT_CITY, $merchantCity);
        // POSTAL CODE
        $postalCode = $this->request->getPost('postalCode');
        if (!preg_match('/^\d{5}$/', $postalCode)) {
            throw new Exception('Invalid postal code');
        }
        $qrString .= $this->formatTag(self::TAG_MERCHANT_CITY, $postalCode);
        // CRC
        $qrString = $this->appendEmvcoCrc($qrString);
        log_message('info', 'GENERATOR:TH:' . $qrString);
        return $this->generateQrCode($qrString, self::COUNTRY_CODE_TH, $this->promptpayColor);
    }

    /**
     * Generate Payment QR Code
     * @throws Exception
     */
    public function generator(): ResponseInterface
    {
        $countryCode = $this->request->getPost('countryCode');
        $countryCode = strtoupper($countryCode);
        try {
            if (self::COUNTRY_CODE_TH == $countryCode) {
                return $this->generatePromptPayQr();
            }
            throw new Exception('Country code not supported');
        } catch (Exception $e) {
            log_message('error', 'ERROR:' . $e->getMessage());
            return $this->response
                ->setStatusCode(HTTP_STATUS_ERROR)
                ->setJSON(['error' => $e->getMessage()]);
        }
    }

    // READER ////////////////////////////////////////////////////////////////

    /**
     * Read QR Code String
     * @return ResponseInterface
     */
    public function reader(): ResponseInterface
    {
        $qrString = $this->request->getPost('qrString');
        log_message('error', 'READER:' . $qrString);
        $contents = [];
        try {
            // VALIDATE QR STRING
            $qrContent = substr($qrString, 0, -8);
            $crcValue  = substr($qrString, -4);
            $chkCrc    = $this->appendEmvcoCrc($qrContent, true);
            if ($chkCrc != $crcValue) {
                throw new Exception('Invalid CRC');
            }
            // DECODE QR STRING
            while (!empty($qrString)) {
                $tagId = intval(substr($qrString, 0, 2));
                $length = intval(substr($qrString, 2, 2));
                if ($length <= 0 || $length > 99 || $tagId < 0) {
                    throw new Exception('Invalid QR Code');
                }
                $value = substr($qrString, 4, $length);
                if (strlen($value) != $length) {
                    throw new Exception('Invalid QR Code');
                }
                if (in_array($tagId, [29, 30])) {
                    $subString = $value;
                    $subContents = [];
                    while (!empty($subString)) {
                        $subTagId = intval(substr($subString, 0, 2));
                        $subLength = intval(substr($subString, 2, 2));
                        if ($subLength <= 0 || $subLength > 99 || $subTagId < 0) {
                            throw new Exception('Invalid QR Code');
                        }
                        $subValue = substr($subString, 4, $subLength);
                        if (strlen($subValue) != $subLength) {
                            throw new Exception('Invalid QR Code');
                        }
                        $subTagId = sprintf('%02d', $subTagId);
                        $subContents[$subTagId] = $subValue;
                        $subString = substr($subString, 4 + $subLength);
                    }
                    $tagId = sprintf('%02d', $tagId);
                    $contents[$tagId] = $subContents;
                } else {
                    $tagId = sprintf('%02d', $tagId);
                    $contents[$tagId] = $value;
                }
                $qrString = substr($qrString, 4 + $length);
            }
            log_message('info', 'READER:' . json_encode($contents));
            return $this->response->setJSON($contents);
        } catch (Exception $e) {
            log_message('error', 'ERROR:' . $e->getMessage());
            return $this->response
                ->setStatusCode(HTTP_STATUS_ERROR)
                ->setJSON(['error' => $e->getMessage()]);
        }
    }
}