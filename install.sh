#!/bin/bash

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python  3 is required for this installation. Please install Python  3 and try again."
    exit  1
fi

# Define the target directory for eve.pyc
EVE_PYC_TARGET_DIR="$HOME/.cli/"

# Check if the target directory for eve.pyc exists and create it if it doesn't
if [ ! -d "$EVE_PYC_TARGET_DIR" ]; then
    mkdir -p "$EVE_PYC_TARGET_DIR"
    if [ $? -ne  0 ]; then
        echo "Error: Failed to create the target directory $EVE_PYC_TARGET_DIR."
        exit  1
    fi
fi

# Check if the user has write permissions to the target directory for eve.pyc
if [ ! -w "$EVE_PYC_TARGET_DIR" ]; then
    echo "Error: You do not have write permissions to $EVE_PYC_TARGET_DIR. Run the script with sudo."
    exit  1
fi

# Get the latest release tag name
LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/eveeifyeve/cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Construct the URLs for the assets
EVE_PYC_URL="https://github.com/eveeifyeve/cli/releases/download/$LATEST_RELEASE/eve.py"
EVE_URL="https://github.com/eveeifyeve/cli/releases/download/$LATEST_RELEASE/eve"

# Inform the user that the download is starting
echo "Downloading the latest release of eve.py..."

# Download eve.pyc using curl
curl -o "${EVE_PYC_TARGET_DIR}/eve.py" "${EVE_PYC_URL}"
if [ $? -ne  0 ]; then
    echo "Error: Failed to download eve.py."
    exit  1
fi

# Change permissions of eve.pyc if necessary
chmod +x "${EVE_PYC_TARGET_DIR}/eve.py"

# Download eve using curl
echo "Downloading the latest release of eve..."
curl -o "/usr/local/bin/eve" "${EVE_URL}"
if [ $? -ne  0 ]; then
    echo "Error: Failed to download eve."
    exit  1
fi

# Change permissions of eve if necessary
chmod +x "/usr/local/bin/eve"

# Install the click package using pip3
echo "Installing the click package..."
pip3 install click
if [ $? -ne  0 ]; then
    echo "Error: Failed to install the click package."
    exit  1
fi

echo "Success: Files downloaded and installed successfully. You can now run 'eve' from anywhere."