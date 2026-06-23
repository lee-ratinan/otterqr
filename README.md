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
| `merchantName`               | string    | max 25 | M    | The registered name of the merchant.                                                                                                                                                                                                              |
| `merchantCity`               | string    | max 15 | M    | The city location of the merchant.                                                                                                                                                                                                                |
| `postalCode`                 | number    | 5      | M    | The 5-digit postal code of the merchant location.                                                                                                                                                                                                 |

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
JSON object containing the decoded data.

## Requirement Legend
- M: Mandatory
- C: Conditional (Required depending on other fields)
- O: Optional