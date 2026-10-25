buat_arsip() {
    sumber=$1
    tujuan=$2
    nama="backup_$(basename "$sumber")_$(date +%Y%m%d_%H%M%S).tar.gz"

    tar -czf "$tujuan/$nama" -C "$(dirname "$sumber")" "$(basename "$sumber")" || return 1
    (cd "$tujuan" && sha256sum "$nama" > "$nama.sha256") || return 1
    echo "$tujuan/$nama"
}

verifikasi_arsip() {
    file=$1
    (cd "$(dirname "$file")" && sha256sum -c "$(basename "$file").sha256" > /dev/null 2>&1)
}

rollback_arsip() {
    tujuan=$1
    terakhir=$(ls -t "$tujuan"/backup_*.tar.gz 2>/dev/null | head -1)
    if [ -z "$terakhir" ]; then
        return 1
    fi
    rm -f "$terakhir" "$terakhir.sha256"
    echo "$terakhir"
}