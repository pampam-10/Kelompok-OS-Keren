#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/lib/log.sh"
source "$BASE_DIR/lib/arsip.sh"

if [ -f "$BASE_DIR/config/backup.conf" ]; then
    source "$BASE_DIR/config/backup.conf"
fi

MODE="backup"

while getopts "s:d:rh" opt; do
    case $opt in
        s) SUMBER=$OPTARG ;;
        d) TUJUAN=$OPTARG ;;
        r) MODE="rollback" ;;
        h) echo "Pemakaian: $0 -s <sumber> -d <tujuan> [-r]"; exit 0 ;;
        *) echo "Opsi tidak dikenal"; exit 1 ;;
    esac
done

if [ -z "$TUJUAN" ]; then
    catat ERROR "Parameter tujuan (-d) wajib diisi"
    exit 1
fi

if [ "$MODE" = "rollback" ]; then
    hasil=$(rollback_arsip "$TUJUAN")
    if [ $? -ne 0 ]; then
        catat ERROR "Tidak ada arsip untuk di-rollback di $TUJUAN"
        exit 6
    fi
    catat INFO "Rollback berhasil, arsip dihapus: $hasil"
    exit 0
fi

if [ -z "$SUMBER" ]; then
    catat ERROR "Parameter sumber (-s) wajib diisi"
    exit 1
fi

if [ ! -d "$SUMBER" ] || [ ! -r "$SUMBER" ]; then
    catat ERROR "Direktori sumber tidak ditemukan atau tidak bisa dibaca: $SUMBER"
    exit 2
fi

mkdir -p "$TUJUAN" 2>/dev/null
if [ ! -d "$TUJUAN" ] || [ ! -w "$TUJUAN" ]; then
    catat ERROR "Direktori tujuan tidak bisa ditulis: $TUJUAN"
    exit 3
fi

catat INFO "Mulai backup $SUMBER ke $TUJUAN"

arsip=$(buat_arsip "$SUMBER" "$TUJUAN")
if [ $? -ne 0 ]; then
    catat ERROR "Gagal membuat arsip"
    exit 4
fi

if ! verifikasi_arsip "$arsip"; then
    catat ERROR "Checksum tidak cocok, arsip dihapus: $arsip"
    rm -f "$arsip" "$arsip.sha256"
    exit 5
fi

catat INFO "Backup berhasil: $arsip"
exit 0