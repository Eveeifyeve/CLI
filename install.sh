#!/bin/bash

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python  3 is required for this installation. Please install Python  3 and try again."
    exit  1
fi

# Define the target directory
TARGET_DIR="/usr/local/bin/"

# Check if the user has write permissions to the target directory
if [ ! -w "$TARGET_DIR" ]; then
    echo "Error: You do not have write permissions to $TARGET_DIR. Run the script with sudo."
    exit  1
fi

# Get the latest release tag name
LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/eveeifyeve/cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Construct the URLs for the assets
EVE_PYC_URL="https://github.com/eveeifyeve/cli/releases/download/$LATEST_RELEASE/eve.pyc"
EVE_URL="https://github.com/eveeifyeve/cli/releases/download/$LATEST_RELEASE/eve"

# Inform the user that the download is starting
echo "Downloading the latest release of eve.pyc and eve..."

# Download eve.pyc using curl
curl -o "${TARGET_DIR}eve.pyc" "${EVE_PYC_URL}"
if [ $? -ne  0 ]; then
    echo "Error: Failed to download eve.pyc."
    exit  1
fi

# Download eve using curl
curl -o "${TARGET_DIR}eve" "${EVE_URL}"
if [ $? -ne  0 ]; then
    echo "Error: Failed to download eve."
    exit  1
fi

# Change permissions of files if necessary
chmod +x "${TARGET_DIR}eve.pyc"
chmod +x "${TARGET_DIR}eve"

# Install the click package using pip3
echo "Installing the click package..."
pip3 install click
if [ $? -ne  0 ]; then
    echo "Error: Failed to install the click package."
    exit  1
fi

echo "Success: Files downloaded and installed successfully. You can now run 'eve' from anywhere."