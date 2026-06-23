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
    <title>Documentation - README</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.1/github-markdown.min.css">
    <style>
        body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 980px;
            margin: 0 auto;
            padding: 45px;
        }
        @media (max-width: 767px) {
            .body { padding: 15px; }
        }
    </style>
</head>
<body class="markdown-body">

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

</body>
</html>