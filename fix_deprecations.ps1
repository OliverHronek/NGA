# PowerShell script to fix withOpacity deprecation warnings
Write-Host "Fixing withOpacity deprecation warnings..." -ForegroundColor Green

$files = @(
    "lib\presentation\screens\forum\forum_categories_screen.dart",
    "lib\presentation\screens\forum\create_category_screen.dart", 
    "lib\presentation\screens\forum\forum_posts_screen.dart",
    "lib\presentation\screens\forum\post_detail_screen.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Fixing $file..." -ForegroundColor Yellow
        
        # Read content, replace withOpacity, write back
        $content = Get-Content $file -Raw
        $newContent = $content -replace '\.withOpacity\(([0-9.]+)\)', '.withValues(alpha: $1)'
        Set-Content $file $newContent -NoNewline
        
        Write-Host "✅ Fixed $file" -ForegroundColor Green
    } else {
        Write-Host "❌ File not found: $file" -ForegroundColor Red
    }
}

Write-Host "All withOpacity warnings should now be fixed!" -ForegroundColor Green
Write-Host "Run 'flutter analyze' to verify." -ForegroundColor Cyan
