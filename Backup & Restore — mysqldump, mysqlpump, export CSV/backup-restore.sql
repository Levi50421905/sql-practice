-- ============================================================
-- File    : backup_restore.sql
-- Topik   : Backup & Restore — mysqldump, mysqlpump, export CSV
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- Backup & Restore dilakukan dari TERMINAL / COMMAND PROMPT,
-- bukan dari dalam MySQL client.
-- File ini berisi: contoh perintah (sebagai komentar SQL),
-- query pembantu dari dalam MySQL, dan script automation.
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP — Database untuk Latihan Backup
-- ============================================================

CREATE DATABASE IF NOT EXISTS backup_demo;
USE backup_demo;

CREATE TABLE IF NOT EXISTS produk (
    id_produk   INT AUTO_INCREMENT PRIMARY KEY,
    nama        VARCHAR(100),
    kategori    VARCHAR(50),
    harga       INT,
    stok        INT,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS log_transaksi (
    id_log      INT AUTO_INCREMENT PRIMARY KEY,
    id_produk   INT,
    aksi        VARCHAR(20),
    qty         INT,
    tgl         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO produk (nama, kategori, harga, stok) VALUES
    ('Laptop Ultra',   'Elektronik', 14000000, 10),
    ('Mouse Wireless', 'Elektronik',   185000, 50),
    ('Meja Belajar',   'Furniture',   1800000,  8),
    ('Buku SQL',       'Buku',          95000, 40);

INSERT INTO log_transaksi (id_produk, aksi, qty) VALUES
    (1, 'KELUAR', 2), (2, 'KELUAR', 5), (3, 'MASUK', 3);


-- ============================================================
-- SECTION 2: MYSQLDUMP — BACKUP DARI TERMINAL
-- ============================================================
-- Jalankan perintah berikut dari Terminal / Command Prompt,
-- BUKAN dari dalam MySQL client.

/*
=== BACKUP SATU DATABASE ===

mysqldump -u root -p backup_demo > backup_demo_full.sql
  → Backup seluruh isi database backup_demo

mysqldump -u root -p backup_demo produk > backup_produk.sql
  → Backup hanya tabel produk

mysqldump -u root -p --no-data backup_demo > backup_schema_only.sql
  → Backup struktur tabel saja (tanpa data)

mysqldump -u root -p --no-create-info backup_demo > backup_data_only.sql
  → Backup data saja (tanpa CREATE TABLE)


=== BACKUP SEMUA DATABASE ===

mysqldump -u root -p --all-databases > backup_all.sql

mysqldump -u root -p --databases backup_demo poliklinik ecommerce_db > backup_pilihan.sql
  → Backup beberapa database sekaligus


=== BACKUP DENGAN KOMPRESI (lebih hemat storage) ===

mysqldump -u root -p backup_demo | gzip > backup_demo_$(date +%Y%m%d).sql.gz
  → Backup langsung dikompres (Linux/Mac)

mysqldump -u root -p backup_demo | gzip > backup_demo_%date:~-4,4%%date:~-10,2%%date:~-7,2%.sql.gz
  → Windows (pakai Git Bash atau WSL untuk date format)


=== OPSI TAMBAHAN YANG BERGUNA ===

mysqldump -u root -p \
  --single-transaction \     ← untuk InnoDB: backup konsisten tanpa lock tabel
  --routines \               ← sertakan stored procedure & function
  --triggers \               ← sertakan trigger
  --events \                 ← sertakan event scheduler
  backup_demo > backup_lengkap.sql


=== BACKUP REMOTE SERVER ===

mysqldump -u root -p -h 192.168.1.100 -P 3306 backup_demo > backup_remote.sql
*/


-- ============================================================
-- SECTION 3: RESTORE DARI TERMINAL
-- ============================================================

/*
=== RESTORE DATABASE ===

mysql -u root -p backup_demo < backup_demo_full.sql
  → Restore ke database yang sudah ada

mysql -u root -p < backup_all.sql
  → Restore semua database (jika backup pakai --all-databases)


=== RESTORE DENGAN MEMBUAT DATABASE BARU ===

mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS backup_demo_restore;"
mysql -u root -p backup_demo_restore < backup_demo_full.sql


=== RESTORE FILE TERKOMPRESI ===

gunzip -c backup_demo_20250611.sql.gz | mysql -u root -p backup_demo
  → Decompress lalu langsung restore (Linux/Mac)


=== RESTORE TABEL TERTENTU SAJA ===
Jika backup_produk.sql hanya berisi tabel produk:
mysql -u root -p backup_demo < backup_produk.sql
*/


-- ============================================================
-- SECTION 4: EXPORT & IMPORT CSV DARI DALAM MYSQL
-- ============================================================

-- 4.1 Export tabel ke CSV (jalankan dari dalam MySQL client)
SELECT *
FROM produk
INTO OUTFILE '/tmp/produk_export.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- 4.2 Export dengan header kolom (workaround: UNION dengan nama kolom)
SELECT 'id_produk', 'nama', 'kategori', 'harga', 'stok'
UNION ALL
SELECT id_produk, nama, kategori, harga, stok
FROM produk
INTO OUTFILE '/tmp/produk_with_header.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- 4.3 Import CSV ke tabel (LOAD DATA)
/*
LOAD DATA LOCAL INFILE '/tmp/produk_export.csv'
INTO TABLE produk
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(id_produk, nama, kategori, harga, stok);
*/

-- 4.4 Export query tertentu (bukan seluruh tabel)
SELECT nama, kategori, harga
FROM produk
WHERE kategori = 'Elektronik'
INTO OUTFILE '/tmp/elektronik.csv'
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n';


-- ============================================================
-- SECTION 5: BACKUP OTOMATIS — SHELL SCRIPT (REFERENSI)
-- ============================================================

/*
Simpan sebagai: backup_otomatis.sh
Jalankan: chmod +x backup_otomatis.sh && ./backup_otomatis.sh
Atau jadwalkan dengan cron: 0 2 * * * /path/to/backup_otomatis.sh

#!/bin/bash
# =============================================
# Script: backup_otomatis.sh
# Fungsi: Backup MySQL otomatis harian
# =============================================

DB_USER="backup_user"
DB_PASS="Backup@1234"
DB_NAME="backup_demo"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz"
RETENTION_DAYS=7

# Buat direktori jika belum ada
mkdir -p "$BACKUP_DIR"

# Jalankan backup
mysqldump -u "$DB_USER" -p"$DB_PASS" \
  --single-transaction \
  --routines --triggers --events \
  "$DB_NAME" | gzip > "$BACKUP_FILE"

# Log hasil
if [ $? -eq 0 ]; then
    echo "$(date): Backup berhasil → $BACKUP_FILE"
else
    echo "$(date): Backup GAGAL!"
fi

# Hapus backup lebih dari 7 hari
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
echo "$(date): File lama (>$RETENTION_DAYS hari) dihapus"
*/


-- ============================================================
-- SECTION 6: QUERY PEMBANTU DARI DALAM MYSQL
-- ============================================================

-- 6.1 Cek ukuran setiap database
SELECT
    table_schema                          AS nama_database,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS ukuran_mb
FROM information_schema.tables
GROUP BY table_schema
ORDER BY ukuran_mb DESC;

-- 6.2 Cek ukuran setiap tabel di database aktif
SELECT
    table_name                            AS nama_tabel,
    ROUND(data_length / 1024 / 1024, 2)  AS data_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_mb,
    table_rows                            AS estimasi_baris
FROM information_schema.tables
WHERE table_schema = 'backup_demo'
ORDER BY data_mb DESC;

-- 6.3 Cek variabel terkait backup
SHOW VARIABLES LIKE 'secure_file_priv';   -- direktori yang diizinkan untuk INTO OUTFILE
SHOW VARIABLES LIKE 'local_infile';       -- status LOAD DATA LOCAL

-- 6.4 Enable LOAD DATA LOCAL jika belum aktif (jalankan sebagai root)
-- SET GLOBAL local_infile = 1;

-- 6.5 Lihat proses yang sedang berjalan (berguna saat backup lambat)
SHOW PROCESSLIST;

-- 6.6 Lock tabel sebelum backup manual (MyISAM)
-- FLUSH TABLES WITH READ LOCK;
-- ... jalankan mysqldump di terminal lain ...
-- UNLOCK TABLES;