<?php
/**
 * @var string $readmePath The absolute path to the README.md file
 */

// 1. Define the path to README.md (Fallback to root if not passed from Controller)
$filePath = $readmePath ?? ROOTPATH . 'README.md';

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OtterQR - README</title>
    <!-- Favicons -->
    <link href="https://otternova.com/assets/img/favicon.webp" rel="icon">
    <link href="https://otternova.com/assets/img/apple-touch-icon.webp" rel="apple-touch-icon">
    <!-- CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        table {
            width: 100%;
        }
        table td, table th {
            padding: 5px;
        }
        table th {
            background-color: #ddd;
        }
        table tr:nth-child(2n) {
            background-color: #eee;
        }
        h1, h2, h3 {
            margin-top: 20px;
        }
        @media screen and (max-width: 767px) {
            body { padding: 15px; }
            table {
                display: block;
                width: 100%;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch; /* Smooth scrolling on iOS */
            }
        }
    </style>
</head>
<body>
<div class="container">
    <div class="row">
        <div class="col">
            <article>
                <?php
                if (file_exists($filePath)) {
                    // 2. Read the contents of the file
                    $markdownContent = file_get_contents($filePath);

                    // 3. Initialize Parsedown and escape unsafe HTML if necessary
                    $parsedown = new \Parsedown();

                    // Optional: If the README contains user-generated content, uncomment the line below to prevent XSS
                    // $parsedown->setSafeMode(true);

                    // 4. Output the rendered HTML
                    echo $parsedown->text($markdownContent);
                } else {
                    echo "<p>Error: README.md file not found at " . esc($filePath) . "</p>";
                }
                ?>

                <p><a href="<?= base_url('testing') ?>">Click here to test the endpoints.</a></p>
            </article>
        </div>
    </div>
</div>

</body>
</html>