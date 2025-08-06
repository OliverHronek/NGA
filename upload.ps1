#!/usr/bin/env pwsh
# Upload-Skript für NGA Web App

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerHost,
    
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$false)]
    [string]$RemotePath = "/public_html",
    
    [Parameter(Mandatory=$false)]
    [switch]$UseSFTP
)

Write-Host "🌐 NGA Web App Upload Script" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Überprüfen ob Build-Verzeichnis existiert
$buildPath = "build\web"
if (-not (Test-Path $buildPath)) {
    Write-Host "❌ Build directory not found! Run deploy.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "📁 Source: $buildPath" -ForegroundColor Cyan
Write-Host "🌐 Target: ${Username}@${ServerHost}:${RemotePath}" -ForegroundColor Cyan

# Passwort sicher abfragen
$SecurePassword = Read-Host "Enter password for $Username" -AsSecureString

if ($UseSFTP) {
    Write-Host "🔒 Using SFTP..." -ForegroundColor Yellow
    
    # SFTP-Kommandos generieren
    $sftpCommands = @"
cd $RemotePath
put -r $buildPath/*
bye
"@
    
    Write-Host "📤 Uploading files via SFTP..." -ForegroundColor Yellow
    Write-Host "Note: This requires sftp client to be installed" -ForegroundColor Yellow
    Write-Host "SFTP Commands to run:" -ForegroundColor Cyan
    Write-Host $sftpCommands -ForegroundColor White
    
} else {
    Write-Host "📤 FTP Upload Instructions:" -ForegroundColor Yellow
    Write-Host "1. Connect to: $ServerHost" -ForegroundColor White
    Write-Host "2. Login as: $Username" -ForegroundColor White
    Write-Host "3. Navigate to: $RemotePath" -ForegroundColor White
    Write-Host "4. Upload all files from: $buildPath" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "💡 Recommended FTP clients:" -ForegroundColor Cyan
    Write-Host "   - FileZilla (free)" -ForegroundColor White
    Write-Host "   - WinSCP (Windows)" -ForegroundColor White
    Write-Host "   - VS Code Extensions (SFTP/FTP)" -ForegroundColor White
}

Write-Host "" -ForegroundColor White
Write-Host "📋 Files to upload:" -ForegroundColor Yellow
Get-ChildItem $buildPath | ForEach-Object { Write-Host "   - $($_.Name)" -ForegroundColor White }

Write-Host "" -ForegroundColor White
Write-Host "⚠️  Important after upload:" -ForegroundColor Red
Write-Host "   1. Configure web server for SPA routing" -ForegroundColor White
Write-Host "   2. Test the deployed app in browser" -ForegroundColor White
Write-Host "   3. Verify all API endpoints work" -ForegroundColor White
Write-Host "   4. Check Google Analytics tracking" -ForegroundColor White

Write-Host "✨ Upload preparation complete!" -ForegroundColor Green
