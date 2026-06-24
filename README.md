# OtterQR API Reference

## Supported Countries

Currently, the following countries and local payment networks are supported:

- Thailand (PromptPay)

## Endpoints: Generate QR Code

### Thailand PromptPay

#### Endpoint
`POST /generator`

#### Request Body
| Key                          | Data Type | Length | Req. | Description                                                                                                                                                                                                                                       |
|------------------------------|-----------|--------|------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `countryCode`                | string    | 2      | M    | Must always be `TH` for Thailand.                                                                                                                                                                                                                 |
| `pointOfInitiation`          | string    | -      | M    | `STATIC`: For standard QR codes without a pre-set transaction amount. <br/> `DYNAMIC`: For QR codes with a specific transaction amount. (Must be `DYNAMIC` if `merchantAccountInformation` is set to `BILL_PAYMENT`).                             |
| `merchantAccountInformation` | string    | -      | M    | `BILL_PAYMENT`: For commercial clients using a dynamic amount and reference number(s). <br/> `PROMPTPAY_ID`: For standard clients using a mobile phone number to receive payments.                                                                |
| `billerId`                   | string    | 15     | C    | **Required if `merchantAccountInformation` is `BILL_PAYMENT`.** <br/><br/> The 15-digit Tax ID + suffix issued by the financial institution identifying the beneficiary.                                                                          |
| `ref1`                       | string    | max 20 | C    | **Required if `merchantAccountInformation` is `BILL_PAYMENT`.** <br/><br/> A unique, non-reusable transaction reference ID. <br/><br/> *Recommendation: Automatically generate this via the OtterNova system.*                                    |
| `ref2`                       | string    | max 20 | O    | **Only valid if `merchantAccountInformation` is `BILL_PAYMENT`.** <br/><br/> An optional, non-reusable secondary transaction reference ID. <br/><br/> *Recommendation: Client-generated id from OtterNova’s integration partner.*                 |
| `phoneNumber`                | string    | 12     | C    | **Required if `merchantAccountInformation` is `PROMPTPAY_ID`.** <br/><br/> The recipient’s phone number in E.164 format (e.g., `+66123456789` instead of `0123456789`).                                                                           |
| `transactionAmount`          | string    | max 13 | C    | **Required if `pointOfInitiation` is `DYNAMIC` or `merchantAccountInformation` is `BILL_PAYMENT`.** <br/><br/> The payment amount in THB. Formatted with up to 2 decimal places using a dot (.) separator. <br/><br/> - Example: `99` or `89.50`. |
| `merchantName`               | string    | max 25 | O    | **Only valid if `merchantAccountInformation` is `BILL_PAYMENT`.** <br/><br/> An optional, registered name of the merchant.                                                                                                                        |

#### Response Body
PNG image of the generated QR code.

### Reader Endpoint
#### The Endpoint
`POST /reader`

#### Request Body
| Key        | Data Type | Length | Req. | Description                       |
|------------|-----------|--------|------|-----------------------------------|
| `qrString` | string    | -      | M    | The QR code string to be decoded. |

#### Response Body
JSON object containing the decoded data. The structure is dynamic based on the QR code raw information.

### Error Response

When there is an error in the request, the API will return a `500` HTTP Status along with a JSON object.

#### Error Response Object
| Key     | Data Type | Description                     |
|---------|-----------|---------------------------------|
| `error` | string    | A human-readable error message. |

#### Notes on the Test Cases

When testing the QR code generation using the real banking applications, here are some observations:

- Although some QR codes contain `merchantName` field (tag ID 59), it is not required at all. Instead, the field can be anything or completely omitted. The banking applications will call the lookup API to get the registered merchant names from the database.
- The field `ref2` (for `BILL_PAYMENT`) is stated in all documents that they are not required, but for some reason, some banking applications still require it.

### List of Error Messages

#### Generator

| Error Message                                               | Description                                                                                    |
|-------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| `Country code not supported`                                | The country code must be `TH`.                                                                 |
| `Point of initiation not supported`                         | The point of initiation must be `DYNAMIC` or `STATIC`                                          |
| `Merchant account information not supported`                | Merchant account information must be `BILL_PAYMENT` or `PROMPTPAY_ID`                          |
| `Bill payment not supported for static point of initiation` | When merchant account information is `BILL_PAYMENT`, the point of initiation must be `DYNAMIC` |
| `Invalid biller ID`                                         | Biller ID must match this REGEX `/^\d{15}$/`                                                   |
| `Invalid reference 1`                                       | Reference number 1 must match this REGEX `/[A-Za-z0-9]{1,20}/`                                 |
| `Invalid reference 2`                                       | If used, reference number 2 must match this REGEX `/[A-Za-z0-9]{1,20}/`                        |
| `Invalid phone number`                                      | Phone number must match this REGEX `/^66\d{9}$/`                                               |
| `Invalid transaction amount`                                | Transaction amount must match this REGEX `/^\d+(\.\d{2})?$/`                                   |
| `Transaction amount too long`                               | Transaction amount must be 13-character long or less                                           |
| `Invalid merchant name`                                     | Merchant name must match this REGEX `/^[A-Za-z0-9 \-.]{1,25}$/`                                |
| `Merchant name not supported for PromptPay ID`              | Merchant name is not supported when merchant account information is `PROMPTPAY_ID`             |

#### Reader

| Error Message     | Description                                     |
|-------------------|-------------------------------------------------|
| `Invalid CRC`     | CRC code is invalid.                            |
| `Invalid QR Code` | The QR code is invalid due to tag ID or length. |

## Requirement Legend
- M: Mandatory
- C: Conditional (Required depending on other fields)
- O: Optional