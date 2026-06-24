# QR Code Specification

## 1. Data Objects

|   Tag ID   | Name                                | Detail                                                                                                                                                                                                                     |
|:----------:|-------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|    `00`    | Payload Format Indicator            | Defines the version of the QR Code template, mostly it is `01` in all standards.                                                                                                                                           |
|    `01`    | Point of Initiation Method          | A value of `11` for static QR Codes and <br/> A value of `12` for dynamic QR Codes.                                                                                                                                        |
| `02`-`51`  | Merchant Account Information        | Identifies the merchant.                                                                                                                                                                                                   |
|    `52`    | Merchant Category Code              | The category code as defined by `ISO 18245`.                                                                                                                                                                               |
|    `53`    | Transaction Currency                | The currency code as defined by `ISO 4217`.                                                                                                                                                                                |
|    `54`    | Transaction Amount                  | The transaction amount (excluding tips and convenience fees), if known. It is required when field `01` is `12`.                                                                                                            |
|    `55`    | Tip or Convenience Indicator        | The mode of the tip/convenience fee: <br/> `01` is used to prompt the user to enter the amount, <br/> `02` is used to define the fixed fee (field `56`), and <br/> `03` is used to define the percentage fee (field `57`). |
|    `56`    | Value of Convenience Fee Fixed      | The fixed convenience fee to be added to the transaction amount, it is required if the field `55` is `02`.                                                                                                                 |
|    `57`    | Value of Convenience Fee Percentage | The percentage convenience fee to be calculated from the transaction amount, it is required if the field `55` is `03`.                                                                                                     |
|    `58`    | Country Code                        | The country code as defined by `ISO 3166-1 alpha 2`.                                                                                                                                                                       |
|    `59`    | Merchant Name                       | The official merchant name.                                                                                                                                                                                                |
|    `60`    | Merchant City                       | The city of operations for the merchant.                                                                                                                                                                                   |
|    `61`    | Merchant Postal Code                | The postal code or PIN code or Postal code of the merchant.                                                                                                                                                                |
|    `62`    | Additional Data Field Template      | The additional data (if any).                                                                                                                                                                                              |
|    `64`    | Language Template                   | The detail of the QR code in other languages.                                                                                                                                                                              |
| `65`-`79`  | Reserved for future use             |                                                                                                                                                                                                                            |
| `80`-`99`  | Unreserved Templates                |                                                                                                                                                                                                                            |
|    `63`    | CRC                                 | The checksum calculated over all the data objects included in the QR Code.                                                                                                                                                 |

## 2. Requirements by Standards

| Tag ID | Thailand’s Promptpay ID                           | Thailand’s Bill Payment Mode                        | Singapore’s PayNow                     |
|:------:|---------------------------------------------------|-----------------------------------------------------|----------------------------------------|
|  `00`  | `01`                                              | `01`                                                | `01`                                   |
|  `01`  | Either `11` or `12`                               | Only `12` as it is used for individual bill payment | Either `11` or `12`                    |
|  `26`  | -                                                 | -                                                   | **Required**                           |
|        | -                                                 | -                                                   | `00` Application ID: `SG.PAYNOW`       |
|        | -                                                 | -                                                   | `01` ? Length = 1                      |
|        | -                                                 | -                                                   | `02` UEN or ID                         |
|        | -                                                 | -                                                   | `03` ? Length = 1                      |
|  `29`  | **Required**                                      | -                                                   | -                                      |
|        | `00` Application ID: `A000000677010111`           |                                                     |                                        |
|        | `01` Promptpay ID (mobile phone): `0066#########` |                                                     |                                        |
|        | `02` Promptpay ID (tax ID, personal ID): `N(13)`  |                                                     |                                        |
|  `30`  | -                                                 | **Required**                                        | -                                      |
|        |                                                   | `00` Application ID: `A000000677010112`             |                                        |
|        |                                                   | `01` Biller ID (tax ID+suffix): `N(15)`             |                                        |
|        |                                                   | `02` Reference number 1: `ans(30)`                  |                                        |
|        |                                                   | `03` Reference number 2: `ans(30)`                  |                                        |
|  `51`  | -                                                 | -                                                   | **Required**                           |
|        | -                                                 | -                                                   | `00` Application ID: `SG.SGQR`         |
|        | -                                                 | -                                                   | `01` Some ID, Length = 12              |
|        | -                                                 | -                                                   | `02` Some value, Length = 7, `01.0001` |
|        | -                                                 | -                                                   | `03` Some value, Length = 6            |
|        | -                                                 | -                                                   | `04` Some value, Length = 2            |
|        | -                                                 | -                                                   | `05` Some value, Length = 2            |
|        | -                                                 | -                                                   | `06` Some value, Length = 4            |
|        | -                                                 | -                                                   | `07` Expiry date: `YYYYMMDD`           |
|  `52`  | -                                                 | -                                                   | `0000`                                 |
|  `53`  | `764`                                             | `764`                                               | `702`                                  |
|  `54`  | Required if `01` is `12`                          | **Required**                                        | Required if `01` is `12`               |
|  `55`  | -                                                 | -                                                   | -                                      |
|  `56`  | -                                                 | -                                                   | -                                      |
|  `57`  | -                                                 | -                                                   | -                                      |
|  `58`  | `TH`                                              | `TH`                                                | `SG`                                   |
|  `59`  | -                                                 | *Optional*                                          | *Optional* ?                           |
|  `60`  | -                                                 | -                                                   | `SINGAPORE`                            |
|  `61`  | -                                                 | -                                                   | *Optional*                             |
|  `62`  | -                                                 | -                                                   | -                                      |
|  `63`  | **Required**                                      | **Required**                                        | **Required**                           |