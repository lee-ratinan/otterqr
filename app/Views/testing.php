<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OtterQR - TESTER</title>
    <!-- Favicons -->
    <link href="https://otternova.com/assets/img/favicon.webp" rel="icon">
    <link href="https://otternova.com/assets/img/apple-touch-icon.webp" rel="apple-touch-icon">
    <!-- CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding: 20px; background-color: #f8f9fa; }
        .card { margin-bottom: 20px; }
        .error-log { color: #dc3545; background-color: #f8d7da; padding: 10px; border-radius: 4px; display: none; white-space: pre-wrap; }
        #qrResponseImage { max-width: 100%; height: auto; display: none; border: 1px solid #dee2e6; padding: 5px; }
        pre { background-color: #f1f1f1; padding: 15px; border-radius: 4px; }
    </style>
</head>
<body>

<div class="container">
    <h1 class="mb-4">API Endpoint Testing Facility</h1>
    <p><a href="<?= base_url() ?>">Back to API Reference</a></p>
    <div class="row">

        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white"><h5 class="mb-0">POST /generator</h5></div>
                <div class="card-body">
                    <form id="generatorForm">

                        <div class="mb-3">
                            <label class="form-label">countryCode</label>
                            <select class="form-select" name="countryCode" required>
                                <option value="TH">TH</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">pointOfInitiation</label>
                            <select class="form-select" name="pointOfInitiation" id="pointOfInitiation" required>
                                <option value="STATIC">STATIC</option>
                                <option value="DYNAMIC">DYNAMIC</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">merchantAccountInformation</label>
                            <select class="form-select" name="merchantAccountInformation" id="merchantAccountInformation" required>
                                <option value="PROMPTPAY_ID">PROMPTPAY_ID</option>
                                <option value="BILL_PAYMENT">BILL_PAYMENT</option>
                            </select>
                        </div>

                        <div class="mb-3" id="divBillerId" style="display:none;">
                            <label class="form-label">billerId (15 numeric digits)</label>
                            <input type="text" class="form-control" name="billerId" pattern="\d{15}" title="Must be exactly 15 digits" maxlength="15">
                        </div>

                        <div class="mb-3" id="divRef1" style="display:none;">
                            <label class="form-label">ref1 (Max 20 alphanumeric)</label>
                            <input type="text" class="form-control" name="ref1" maxlength="20">
                        </div>

                        <div class="mb-3" id="divRef2" style="display:none;">
                            <label class="form-label">ref2 (Optional, Max 20 alphanumeric)</label>
                            <input type="text" class="form-control" name="ref2" maxlength="20">
                        </div>

                        <div class="mb-3" id="divPhoneNumber">
                            <label class="form-label">phoneNumber (+66 followed by 9 digits)</label>
                            <input type="text" class="form-control" name="phoneNumber" value="" pattern="\+66\d{9}" title="Format: +66XXXXXXXXX">
                        </div>

                        <div class="mb-3" id="divTransactionAmount" style="display:none;">
                            <label class="form-label">transactionAmount (Max 13 chars)</label>
                            <input type="text" class="form-control" name="transactionAmount" maxlength="13">
                        </div>

                        <div class="mb-3" id="divMerchantName" style="display:none;">
                            <label class="form-label">merchantName (Optional, Max 25 alphanumeric/spaces)</label>
                            <input type="text" class="form-control" name="merchantName" maxlength="25" pattern="[a-zA-Z0-9 ]*">
                        </div>

                        <button type="submit" class="btn btn-primary w-100">Submit to /generator</button>
                    </form>

                    <div class="mt-4">
                        <h6>Result:</h6>
                        <div id="generatorError" class="error-log mb-2"></div>
                        <img id="qrResponseImage" alt="Generated QR Code">
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header bg-success text-white"><h5 class="mb-0">POST /reader</h5></div>
                <div class="card-body">
                    <form id="readerForm">
                        <div class="mb-3">
                            <label class="form-label">qrString</label>
                            <textarea class="form-control" name="qrString" rows="4" required placeholder="Paste QR string here..."></textarea>
                        </div>
                        <button type="submit" class="btn btn-success w-100">Submit to /reader</button>
                    </form>

                    <div class="mt-4">
                        <h6>Result JSON:</h6>
                        <div id="readerError" class="error-log mb-2"></div>
                        <pre id="readerResponseJSON">No data received yet.</pre>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
    // --- UI Logic: Dynamic Field Toggling ---
    const poiSelect = document.getElementById('pointOfInitiation');
    const maiSelect = document.getElementById('merchantAccountInformation');

    function toggleFields() {
        const poi = poiSelect.value;
        const mai = maiSelect.value;

        // Conditionals for merchant account info
        if (mai === 'BILL_PAYMENT') {
            document.getElementById('divBillerId').style.display = 'block';
            document.getElementById('divRef1').style.display = 'block';
            document.getElementById('divRef2').style.display = 'block';
            document.getElementById('divMerchantName').style.display = 'block';
            document.getElementById('divPhoneNumber').style.display = 'none';

            document.querySelector('[name="billerId"]').required = true;
            document.querySelector('[name="ref1"]').required = true;
            document.querySelector('[name="phoneNumber"]').required = false;
        } else { // PROMPTPAY_ID
            document.getElementById('divBillerId').style.display = 'none';
            document.getElementById('divRef1').style.display = 'none';
            document.getElementById('divRef2').style.display = 'none';
            document.getElementById('divMerchantName').style.display = 'none';
            document.getElementById('divPhoneNumber').style.display = 'block';
            document.querySelector('[name="billerId"]').required = false;
            document.querySelector('[name="ref1"]').required = false;
            document.querySelector('[name="phoneNumber"]').required = true;
        }

        // Conditionals for point of initiation
        if (poi === 'DYNAMIC') {
            document.getElementById('divTransactionAmount').style.display = 'block';
            document.querySelector('[name="transactionAmount"]').required = true;
        } else { // STATIC
            document.getElementById('divTransactionAmount').style.display = 'none';
            document.querySelector('[name="transactionAmount"]').required = false;
        }
    }

    poiSelect.addEventListener('change', toggleFields);
    maiSelect.addEventListener('change', toggleFields);
    toggleFields(); // Run initial setup


    // --- API Logic: POST /generator ---
    document.getElementById('generatorForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const imgElement = document.getElementById('qrResponseImage');
        const errorElement = document.getElementById('generatorError');

        // Reset states
        imgElement.style.display = 'none';
        errorElement.style.display = 'none';

        const formData = new FormData(this);

        try {
            const response = await fetch('/generator', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`HTTP Error ${response.status}: ${response.statusText}`);
            }

            // Read response as a binary blob (PNG)
            const blob = await response.blob();
            const objectURL = URL.createObjectURL(blob);

            imgElement.src = objectURL;
            imgElement.style.display = 'block';

        } catch (error) {
            errorElement.textContent = `Submission Failed: ${error.message}`;
            errorElement.style.display = 'block';
        }
    });


    // --- API Logic: POST /reader ---
    document.getElementById('readerForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const jsonElement = document.getElementById('readerResponseJSON');
        const errorElement = document.getElementById('readerError');

        // Reset states
        jsonElement.textContent = "Waiting for response...";
        errorElement.style.display = 'none';

        const formData = new FormData(this);

        try {
            const response = await fetch('/reader', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`HTTP Error ${response.status}: ${response.statusText}`);
            }

            const jsonResult = await response.json();
            jsonElement.textContent = JSON.stringify(jsonResult, null, 4);

        } catch (error) {
            jsonElement.textContent = "Failed to parse.";
            errorElement.textContent = `Submission Failed: ${error.message}`;
            errorElement.style.display = 'block';
        }
    });
</script>

</body>
</html>