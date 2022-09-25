#!/bin/bash
cd /opt 
URL="https://www.kakuros.com/?s=9x8"
COUNT=125
PERPDF=15
NAME="kakuro-$(date +%Y%m%d)-"

_dl() {
    local f
    rm -f *.html
    for f in $(seq 0 $COUNT); do
        curl "$URL" > kakuro.$f.html
        sleep 1
    done
}

_pdfs() {
    local f
    rm -f *.pdf
    for f in $(ls | grep '\.html$'); do
        cat $f | wkhtmltopdf - $f.pdf
        sleep 1
    done
}

_flush() {
    local cnt
    cnt=$(ls | grep '\.jpg$' | wc -l)
    if [ $cnt -eq 0 ]; then
       return
    fi 
    if [ $cnt -ge $PERPDF ] || [ $2 -eq 1 ]; then
        echo "syncing: $cnt to $1"
        mv *.jpg /results
        (cd /results && convert *.jpg $NAME$1.pdf)
        rm /results/*.jpg
    fi
}

_img() {
    local f jpg idx cnt
    idx=0
    for f in $(ls | grep '\.pdf$'); do
        jpg=$f.jpg
        pdftoppm -f 1 -l 1 -jpeg -x 100 -y 250 -W 700 -H 520 $f > $jpg
        _flush $idx 0
        idx=$((idx+1))
    done
    _flush $idx 1
}

_dl
_pdfs
_img
