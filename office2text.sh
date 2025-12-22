#!/bin/sh
# office2text.sh - конвертер офисных файлов в plain text

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

input_file="$1"

file_type=$(file -b --mime-type "$input_file" | tr '[:upper:]' '[:lower:]')

#echo "Defined file type - $file_type"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

case "$file_type" in
    *pdf*)
        # PDF 
        if command_exists pdftotext; then
            pdftotext -layout -enc UTF-8 "$input_file" -
            exit $?
        fi
        ;;
    *msword*|*wordprocessing*)
        #  Word
        if echo "$input_file" | grep -qi '\.docx\?$'; then
            if command_exists pandoc; then
                pandoc -f docx -t plain "$input_file" -o -
                exit $?
            elif command_exists docx2txt; then
                docx2txt "$input_file" -
                exit $?
            elif command_exists unzip; then
                temp_dir=$(mktemp -d)
                unzip -qq -o "$input_file" -d "$temp_dir" 'word/document*.xml' 2>/dev/null
                if [ -f "$temp_dir/word/document.xml" ]; then
                    sed 's/<[^>]*>//g' "$temp_dir/word/document.xml"
                    rm -rf "$temp_dir"
                    exit 0
                fi
                rm -rf "$temp_dir"
            fi
        else
            # .doc файлы
            if command_exists antiword; then
                antiword "$input_file"
                exit $?
            elif command_exists catdoc; then
                catdoc "$input_file"
                exit $?
            fi
        fi
        ;;
    *text/plain*)
        # plain text 
        if command_exists cat; then
        cat "$input_file"
        exit 0
        fi
        ;;
    *)
    # Попробуем LibreOffice как универсальный конвертер
    if command_exists soffice; then
        temp_dir=$(mktemp -d)
        temp_output="$temp_dir/$(basename "$input_file" | sed 's/\.[^.]*$//').txt"
        
        if soffice --headless --convert-to txt:Text --outdir "$temp_dir" "$input_file" >/dev/null 2>&1; then
            if [ -f "$temp_output" ]; then
                cat "$temp_output"
                rm -rf "$temp_dir"
                exit 0
            else
                converted_file=$(find "$temp_dir" -name '*.txt' -type f -print -quit)
                if [ -f "$converted_file" ]; then
                    cat "$converted_file"
                    rm -rf "$temp_dir"
                    exit 0
                fi
            fi
        fi
        rm -rf "$temp_dir"
    fi
    ;;
esac

if command_exists strings; then
    strings "$input_file"
    exit $?
else
    cat "$input_file"
    exit 0
fi