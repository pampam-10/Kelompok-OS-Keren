#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$BASE_DIR/bin/backup.sh"
TMP=$(mktemp -d)

mkdir -p "$BASE_DIR/bukti"
export LOG_FILE="$BASE_DIR/bukti/test.log"
rm -f "$LOG_FILE"

mkdir -p "$TMP/sumber"
echo "isi uji" > "$TMP/sumber/file1.txt"

cek() {
    nama=$1
    harapan=$2
    hasil=$3
    if [ "$hasil" -eq "$harapan" ]; then
        echo "PASS - $nama (exit $hasil)"
    else
        echo "FAIL - $nama (harapan $harapan, hasil $hasil)"
    fi
}

"$SCRIPT" -s "$TMP/sumber" -d "$TMP/tujuan" > /dev/null
cek "TC1 backup berhasil" 0 $?

"$SCRIPT" -s "$TMP/tidak_ada" -d "$TMP/tujuan" > /dev/null
cek "TC2 sumber tidak ada" 2 $?

"$SCRIPT" -s "$TMP/sumber" > /dev/null
cek "TC3 parameter tujuan kosong" 1 $?

"$SCRIPT" -d "$TMP/kosong" -r > /dev/null
cek "TC4 rollback tanpa arsip" 6 $?

echo "Log pengujian: $LOG_FILE"