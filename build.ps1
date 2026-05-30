$mediaDir = "extracted_docx\word\media"
$templatePath = "index.template.html"
$outputPath = "index.html"

if (-not (Test-Path $mediaDir)) {
    Write-Error "Media directory not found: $mediaDir"
    exit 1
}

if (-not (Test-Path $templatePath)) {
    Write-Error "Template file not found: $templatePath"
    exit 1
}

Write-Host "Encoding images..."

# Define mappings of images
$imageMap = @{
    "saudi_oil_chart" = "image2.png"
    "pyramid_a" = "image7.jpg"
    "pyramid_b" = "image6.jpg"
    "pyramid_c" = "image8.jpg"
    "climograph_1" = "image3.png"
    "climograph_2" = "image1.png"
    "appendix_a_israel_climate" = "image4.png"
    "appendix_b_russia_map" = "image5.png"
}

$imagesJs = "const IMAGES = {`n"

foreach ($key in $imageMap.Keys) {
    $fileName = $imageMap[$key]
    $filePath = Join-Path $mediaDir $fileName
    if (-not (Test-Path $filePath)) {
        Write-Warning "File not found: $filePath"
        $imagesJs += "  `"$key`": `"`",`n"
        continue
    }
    
    # Detect mime type
    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
    $mime = "image/png"
    if ($ext -eq ".jpg" -or $ext -eq ".jpeg") {
        $mime = "image/jpeg"
    }
    
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $imagesJs += "  `"$key`": `"data:$mime;base64,$base64`",`n"
    Write-Host "Encoded $fileName as $key"
}

$imagesJs += "};"

Write-Host "Reading template..."
$template = Get-Content -Raw -Encoding utf8 $templatePath
$finalHtml = $template.Replace("// {{IMAGES_PLACEHOLDER}}", $imagesJs)

Write-Host "Writing final index.html..."
[System.IO.File]::WriteAllText($outputPath, $finalHtml, [System.Text.Encoding]::UTF8)

Write-Host "Build complete! index.html generated."
