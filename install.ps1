# Define the target directory for eve.exe and eve.py
$EVE_TARGET_DIR = "$Home\CLI"

# Check if the target directory exists and create it if it doesn't
if (-not (Test-Path -Path $EVE_TARGET_DIR)) {
    New-Item -ItemType Directory -Path $EVE_TARGET_DIR
}

# Get the latest release tag name
$LATEST_RELEASE = Invoke-RestMethod -Uri "https://api.github.com/repos/eveeifyeve/cli/releases/latest" | Select-Object -ExpandProperty tag_name

# Construct the URLs for the assets
$EVE_EXE_URL = "https://github.com/eveeifyeve/cli/releases/download/$LATEST_RELEASE/eve.exe"
$EVE_PY_URL = "https://github.com/eveeifyeve/cli/releases/download/$LATEST_RELEASE/eve.py"

# Inform the user that the download is starting
Write-Host "Downloading the latest release of eve.exe..."

# Download eve.exe using Invoke-WebRequest
Invoke-WebRequest -Uri $EVE_EXE_URL -OutFile "$EVE_TARGET_DIR\eve.exe"

# Inform the user that the download is starting
Write-Host "Downloading the latest release of eve.py..."

# Download eve.py using Invoke-WebRequest
Invoke-WebRequest -Uri $EVE_PY_URL -OutFile "$EVE_TARGET_DIR\eve.py"

# Add the CLI directory to the PATH environment variable
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$EVE_TARGET_DIR", "User")
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User")