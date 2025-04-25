#!/bin/bash

FORCE_FONT="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"

# Check if the URL is provided
if [ -z "$FORCE_FONT" ]; then
    font_url="$1"
else
    font_url="$FORCE_FONT"
fi

if [ -z "$font_url" ]; then
    echo "Please provide a URL to a font zip file."
    exit 1
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Download the font zip file
wget -O "$TEMP_DIR/font.zip" "$font_url"

# Unzip the font file
unzip "$TEMP_DIR/font.zip" -d "$TEMP_DIR"

# Move the font files to the system fonts directory
sudo mv "$TEMP_DIR"/*.{ttf,otf} /usr/local/share/fonts/

# Update the font cache
fc-cache -f -v

# Clean up
rm -rf "$TEMP_DIR"

echo "Fonts installed successfully!"