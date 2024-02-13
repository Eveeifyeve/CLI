#!/usr/bin/env pwsh

# Define the URL where the eve.ps1 script is hosted on GitHub
$scriptUrl = "https://raw.githubusercontent.com/Eveeifyeve/cli/Stable/src/eve.ps1"

# Define the destination path where the script will be saved
$destinationPath = "~/bin/eve.ps1"

# Download the eve.ps1 script
Invoke-WebRequest -Uri $scriptUrl -OutFile $destinationPath

# Ensure the downloaded script is executable
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Output a success message
Write-Host "Installation completed successfully."