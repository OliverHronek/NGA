# Backend Deployment Script for NGA
param(
    [string]$Environment = "production"
)

Write-Host "Backend Deployment Starting..." -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Cyan

$backendPath = "backend"
$deployPath = "deploy-backend"

# Check if backend directory exists
if (-not (Test-Path $backendPath)) {
    Write-Host "Backend directory not found!" -ForegroundColor Red
    exit 1
}

# Create deployment directory
Write-Host "Creating deployment directory..." -ForegroundColor Yellow
if (Test-Path $deployPath) {
    Remove-Item $deployPath -Recurse -Force
}
New-Item -ItemType Directory -Path $deployPath | Out-Null

# Copy backend files
Write-Host "Copying backend files..." -ForegroundColor Yellow
$filesToCopy = @(
    "package.json",
    "package-lock.json", 
    "server.js",
    "controllers",
    "routes", 
    "middleware",
    "models",
    "config",
    "utils"
)

foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $backendPath $file
    if (Test-Path $sourcePath) {
        $targetPath = Join-Path $deployPath $file
        if (Test-Path $sourcePath -PathType Container) {
            Copy-Item $sourcePath $targetPath -Recurse
        } else {
            Copy-Item $sourcePath $targetPath
        }
        Write-Host "Copied: $file" -ForegroundColor Green
    } else {
        Write-Host "Missing: $file" -ForegroundColor Yellow
    }
}

Write-Host "Backend deployment package created in: $deployPath" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Upload files to your server" -ForegroundColor White
Write-Host "2. Install Node.js and dependencies" -ForegroundColor White
Write-Host "3. Configure environment variables" -ForegroundColor White
Write-Host "4. Start the server" -ForegroundColor White
