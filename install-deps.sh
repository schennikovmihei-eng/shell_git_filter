#!/bin/sh
# Install dependencies for Git office textconv

echo "Installing dependencies for Git office diff..."
echo ""

# Detect package manager
if command -v apt-get >/dev/null 2>&1; then
    echo "Detected: apt (Debian/Ubuntu)"
    sudo apt-get update
    sudo apt-get install -y \
        poppler-utils \      # pdftotext
        pandoc \            # docx support
        antiword \          # doc support
        catdoc \            # xls support
        docx2txt \          # alternative docx
        libreoffice-common \ # PPTX support via LibreOffice
        python3-pip
        unoconv \          # PPT/PPTX support

    # Install Python packages
    sudo pip3 install xlsx2csv

elif command -v yum >/dev/null 2>&1; then
    echo "Detected: yum (RHEL/CentOS)"
    sudo yum install -y \
        poppler-utils \
        pandoc \
        antiword \
        catdoc \
        python3-pip
        unoconv \          # PPT/PPTX support

    sudo pip3 install xlsx2csv

elif command -v brew >/dev/null 2>&1; then
    echo "Detected: brew (macOS)"
    brew install \
        poppler \          # pdftotext
        pandoc \
        antiword \
        catdoc \
        docx2txt
        libreoffice-common \ # PPTX support via LibreOffice

    pip3 install xlsx2csv

else
    echo "Could not detect package manager"
    echo "Please install manually:"
    echo "- pdftotext (poppler-utils)"
    echo "- pandoc"
    echo "- antiword or catdoc"
    echo "- xlsx2csv (pip install xlsx2csv)"
    exit 1
fi

echo ""
echo "Dependencies installed!"
echo ""
echo "Available converters:"
echo "--------------------"
command -v pdftotext && echo "• pdftotext (PDF)" || echo "✗ pdftotext"
command -v pandoc && echo "• pandoc (DOCX)" || echo "✗ pandoc"
command -v antiword && echo "• antiword (DOC)" || echo "✗ antiword"
command -v xlsx2csv && echo "• xlsx2csv (XLSX)" || echo "✗ xlsx2csv"
command -v xls2csv && echo "• xls2csv (XLS)" || echo "✗ xls2csv"

echo ""
echo "Now run: ./setup-git.sh"

# Optional: PowerPoint converters
# Uncomment if needed:
# sudo apt-get install -y unoconv  # for PPT/PPTX
# npm install -g pptx2md           # alternative for PPTX
