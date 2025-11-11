$ErrorActionPreference = 'Stop'

# Tìm keytool
$keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
if (-not (Test-Path $keytool)) {
    Write-Host "ERROR: keytool not found at $keytool"
    exit 1
}

# Đường dẫn debug keystore
$debugKeystore = Join-Path $env:USERPROFILE ".android\debug.keystore"
Write-Host "Keystore path: $debugKeystore"

# Tạo thư mục nếu chưa có
$dir = Split-Path $debugKeystore
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "Created directory: $dir"
}

# Tạo keystore nếu chưa có
if (-not (Test-Path $debugKeystore)) {
    Write-Host "Creating debug keystore..."
    & $keytool -genkey -v `
        -keystore $debugKeystore `
        -storepass android `
        -alias androiddebugkey `
        -keypass android `
        -dname "CN=Android Debug,O=Android,C=US" `
        -keyalg RSA -keysize 2048 -validity 10000
    Write-Host "Keystore created successfully!"
}

# Lấy SHA-1 và SHA-256
Write-Host "`n=== SHA-1 and SHA-256 Fingerprints ===" -ForegroundColor Green
& $keytool -list -v `
    -alias androiddebugkey `
    -keystore $debugKeystore `
    -storepass android `
    -keypass android

