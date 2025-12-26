#!/bin/sh
# Git textconv setup for office files
# Использует прямые команды как в условии задания:
# [diff "pdf"]
#     textconv = sh -c 'pdftotext -layout -enc UTF-8 "$0" -'

set -e

echo "Git textconv setup for office files"
echo ""
# Функция проверки команд
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "$1 found"
        return 0
    else
        echo "$1 NOT FOUND"
        echo "    Install: $2"
        return 1
    fi
}

echo "Checking required tools..."

# PDF
if check_command "pdftotext" "poppler-utils (apt-get install poppler-utils)"; then
    git config --global diff.pdf.textconv "sh -c 'pdftotext -layout -enc UTF-8 \"\$0\" -'"
    echo "   Configured: *.pdf → pdftotext -layout -enc UTF-8"
fi

# DOCX
if check_command "pandoc" "pandoc (apt-get install pandoc)"; then
    git config --global diff.docx.textconv "sh -c 'pandoc -f docx -t plain \"\$0\" -o -'"
    echo "   Configured: *.docx → pandoc -f docx -t plain"
elif check_command "docx2txt" "docx2txt (apt-get install docx2txt)"; then
    git config --global diff.docx.textconv "sh -c 'docx2txt \"\$0\" -'"
    echo "   Configured: *.docx → docx2txt"
else
    echo "No DOCX converter found"
fi

# DOC
if check_command "antiword" "antiword (apt-get install antiword)"; then
    git config --global diff.doc.textconv "sh -c 'antiword \"\$0\"'"
    echo "   Configured: *.doc → antiword"
elif check_command "catdoc" "catdoc (apt-get install catdoc)"; then
    git config --global diff.doc.textconv "sh -c 'catdoc \"\$0\"'"
    echo "   Configured: *.doc → catdoc"
else
    echo "No DOC converter found"
fi

# XLSX
if check_command "xlsx2csv" "xlsx2csv (pip install xlsx2csv)"; then
    git config --global diff.xlsx.textconv "sh -c 'xlsx2csv \"\$0\" -'"
    echo "   Configured: *.xlsx → xlsx2csv"
elif check_command "in2csv" "csvkit (pip install csvkit)"; then
    git config --global diff.xlsx.textconv "sh -c 'in2csv \"\$0\"'"
    echo "   Configured: *.xlsx → in2csv"
else
    echo "No XLSX converter found"
fi

# XLS
if check_command "xls2csv" "catdoc (apt-get install catdoc)"; then
    git config --global diff.xls.textconv "sh -c 'xls2csv \"\$0\"'"
    echo "   Configured: *.xls → xls2csv"
fi

# Plain text
git config --global diff.txt.textconv "sh -c 'cat \"\$0\"'"
echo "   Configured: *.txt → cat"

echo ""
echo "Configuration summary"
git config --global --list | grep "^diff\." | sort | sed 's/^/   /'

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Add .gitattributes to your project:"
echo ""
echo "   *.pdf diff=pdf"
echo "   *.docx diff=docx"
echo "   *.xlsx diff=xlsx"
echo ""
echo "2. Test with: git diff <office-file>"
echo ""
echo "Note: Some formats require additional tools."
echo "      Run ./install_dependencies.sh to install all tools."
