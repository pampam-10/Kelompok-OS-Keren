# Kelompok-OS-Keren
Kelompok: Kelompok OS Keren
Anggota: Diandra Farrel, Kenzi Alkhalid, Rakha Zuhdi, Prama Setiaji

# Use case dan tujuan

Backup manual rawan terlupa, dan arsip yang rusak bisa tidak diketahui sampai
dibutuhkan. Script ini mengarsipkan satu direktori ke tar.gz, membuat checksum
SHA256, memverifikasi arsip tersebut, dan mencatat setiap langkah ke log. Tujuannya
agar backup konsisten, bisa diverifikasi, dan mudah ditelusuri bila gagal.

# Struktur repository

- bin/backup.sh : program utama, validasi input, dan exit status
- lib/log.sh : fungsi pencatatan log
- lib/arsip.sh : fungsi buat arsip, verifikasi checksum, dan rollback
- config/backup.conf.example : contoh konfigurasi tanpa credential
- tests/test_backup.sh : test case otomatis
- bukti/ : hasil pengujian dan log asli

# Menjalankan

    git clone https://github.com/pampam-10/Kelompok-OS-Keren.git
    cd Kelompok-OS-Keren
    chmod +x bin/backup.sh tests/test_backup.sh
    ./bin/backup.sh -s /path/sumber -d /path/tujuan

Contoh:

    ./bin/backup.sh -s ~/data_uji -d ~/hasil_backup

# Memverifikasi

    cd /path/tujuan && sha256sum -c backup_xxx.tar.gz.sha256
    cat logs/backup.log

Hasil yang diharapkan dari sha256sum adalah tulisan OK di belakang nama arsip.

# Membersihkan

    rm -rf /path/tujuan logs/

# Rollback

    ./bin/backup.sh -d /path/tujuan -r

Perintah ini menghapus arsip terbaru beserta file checksum-nya. Bila tidak ada
arsip, script berhenti dengan exit status 6.

# Exit status

- 0 : sukses
- 1 : parameter kurang atau opsi tidak dikenal
- 2 : direktori sumber tidak ditemukan atau tidak bisa dibaca
- 3 : direktori tujuan tidak bisa dibuat atau ditulis
- 4 : gagal membuat arsip
- 5 : checksum tidak cocok (arsip dihapus)
- 6 : rollback gagal karena tidak ada arsip

# Pengujian

Jalankan:

    ./tests/test_backup.sh

Test case:

- TC1 : backup berhasil, exit status yang diharapkan 0
- TC2 : sumber tidak ada, exit status yang diharapkan 2
- TC3 : parameter tujuan kosong, exit status yang diharapkan 1
- TC4 : rollback tanpa arsip, exit status yang diharapkan 6

# Hasil pengujian

Hasil aktual test (bukti/hasil_test.txt):

PASS - TC1 backup berhasil (exit 0)
PASS - TC2 sumber tidak ada (exit 2)
PASS - TC3 parameter tujuan kosong (exit 1)
PASS - TC4 rollback tanpa arsip (exit 6)
Log pengujian: /home/prama12345/Kelompok-OS-Keren-1/bukti/test.log

Hasil skenario backup sungguhan di WSL Ubuntu (bukti/catatan_run.txt):
### 1. Backup sukses
[INFO] Mulai backup /home/prama12345/data_uji ke /home/prama12345/hasil_backup
[INFO] Backup berhasil: /home/prama12345/hasil_backup/backup_data_uji_20261025_194706.tar.gz
exit status: 0
### 2. Sumber tidak ada
[ERROR] Direktori sumber tidak ditemukan atau tidak bisa dibaca: /home/prama12345/folder_tidak_ada
exit status: 2
### 3. Parameter tujuan kosong
[ERROR] Parameter tujuan (-d) wajib diisi
exit status: 1
### 4. Isi folder hasil
backup_data_uji_20261025_194706.tar.gz
backup_data_uji_20261025_194706.tar.gz.sha256
### 5. Verifikasi checksum
backup_data_uji_20261025_194706.tar.gz: OK
### 6. Rollback
[INFO] Rollback berhasil, arsip dihapus: /home/prama12345/hasil_backup/backup_data_uji_20261025_194706.tar.gz
exit status: 0
### 7. Rollback saat arsip sudah kosong
[ERROR] Tidak ada arsip untuk di-rollback di /home/prama12345/hasil_backup
exit status: 6

Log aktual ada di bukti/backup.log dan bukti/test.log.

# Interpretasi hasil

Hasil pengujian menunjukkan script berjalan sesuai rancangan pada kondisi berhasil
maupun gagal. Pada kondisi normal, backup direktori data_uji menghasilkan arsip
tar.gz beserta file checksum SHA256, dan verifikasi dengan sha256sum menampilkan
OK, yang berarti isi arsip utuh. Exit status 0 dan log berlevel INFO mengonfirmasi
proses selesai tanpa masalah.

Pada kondisi gagal, script menolak input yang tidak valid sebelum membuat arsip.
Direktori sumber yang tidak ada menghasilkan exit status 2, dan parameter tujuan
yang kosong menghasilkan exit status 1. Keduanya dicatat sebagai ERROR di log
dengan pesan yang menjelaskan penyebabnya, sehingga tidak ada arsip rusak atau
setengah jadi yang tertinggal. Fitur rollback berhasil menghapus arsip terbaru 
beserta checksum-nya (exit status 0), dan ketika dijalankan lagi saat tidak ada
arsip, script berhenti dengan exit status 6 dan mencatat errornya. Ke 4 test case 
menghasilkan pass sesuai exit yang diharapkan. 

Secara keseluruhan, exit status yang berbeda untuk tiap kondisi dan log yang
mencatat waktu serta level kejadian memudahkan penelusuran penyebab kegagalan.
Output dinamis seperti timestamp, nama arsip, dan path pengguna berbeda pada tiap
sistem, tetapi pola hasilnya (exit status dan pesan log) tetap sama.

# Keamanan

Repository ini tidak berisi password, token, private key, atau data pribadi.
File config/backup.conf dan folder logs/ di-ignore lewat .gitignore, hanya
config/backup.conf.example

## Batasan

- Exit status 3, 4, dan 5 sudah ada di kode tetapi belum punya test otomatis
- Belum ada penjadwalan cron dan rotasi arsip lama (rencana P12 sampai P15)

## Kontribusi anggota

- Diandra Farrel Adriansyah: Menulis lib/log.sh, config/backup.conf.example, .gitignore; membuat repo, tag, dan submit
- Kenzi Alkhalid Syahputra: Menulis lib/arsip.sh (arsip, checksum, verifikasi, rollback); pengujian manual checksum
- Rakha Zuhdi Naufal: Menulis bin/backup.sh (validasi parameter, exit status, error handling)
- Prama Jeevanditya Setiaji: Menulis tests/test_backup.sh, mengumpulkan bukti pengujian, menulis README

## Commit atau tag

Tag: P2-CHECKPOINT-P11-v01