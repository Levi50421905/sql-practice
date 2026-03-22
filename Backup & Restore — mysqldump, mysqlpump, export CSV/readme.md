# 💾 Backup & Restore

**Topik:** Backup & Restore Database — `mysqldump`, Export CSV, Otomasi  
**Database:** MariaDB / MySQL  
**Author:** Muhammad Alfarezzi Fallevi · 4IA17 · 50421905

---

## 🧠 Mengapa Backup Penting?

Data adalah aset paling berharga dalam sebuah sistem. Kehilangan data bisa terjadi karena: hardware rusak, human error (salah `DELETE` atau `DROP`), serangan ransomware, atau bug aplikasi. Tanpa backup, data yang hilang tidak bisa dikembalikan.

**Aturan backup yang baik: 3-2-1**
- **3** salinan data (1 asli + 2 backup)
- **2** media yang berbeda (misal: disk lokal + cloud)
- **1** salinan di lokasi berbeda (offsite)

---

## 📖 Metode Backup di MySQL

| Metode | Tool | Kelebihan | Kekurangan |
|---|---|---|---|
| **Logical Backup** | `mysqldump` | Portabel, mudah dipahami, bisa restore parsial | Lebih lambat untuk data besar |
| **CSV Export** | `SELECT INTO OUTFILE` | Ringan, bisa dibuka di Excel | Tidak menyimpan struktur tabel |
| **Binary Backup** | `mysqlpump`, `xtrabackup` | Cepat untuk data besar | Perlu tool tambahan |

---

## 📝 mysqldump — Perintah Lengkap

`mysqldump` dijalankan dari **Terminal / Command Prompt**, bukan dari dalam MySQL client.

### Backup Dasar
```bash
# Satu database
mysqldump -u root -p nama_db > backup.sql

# Tabel tertentu saja
mysqldump -u root -p nama_db nama_tabel > backup_tabel.sql

# Beberapa database sekaligus
mysqldump -u root -p --databases db1 db2 db3 > backup_pilihan.sql

# Semua database
mysqldump -u root -p --all-databases > backup_semua.sql
```

### Backup Parsial
```bash
# Schema saja (tanpa data) — berguna untuk migrasi struktur
mysqldump -u root -p --no-data nama_db > schema_only.sql

# Data saja (tanpa CREATE TABLE) — berguna untuk seed data
mysqldump -u root -p --no-create-info nama_db > data_only.sql
```

### Backup Lengkap (Rekomendasi Produksi)
```bash
mysqldump -u root -p \
  --single-transaction \  ← backup InnoDB konsisten tanpa lock
  --routines \            ← sertakan stored procedure & function
  --triggers \            ← sertakan trigger
  --events \              ← sertakan event scheduler
  nama_db > backup_lengkap.sql
```

### Backup dengan Kompresi
```bash
# Linux / Mac
mysqldump -u root -p nama_db | gzip > backup_$(date +%Y%m%d).sql.gz

# Hemat storage hingga 80% dibanding file .sql biasa
```

---

## 🔄 Restore Database

```bash
# Restore ke database yang sudah ada
mysql -u root -p nama_db < backup.sql

# Restore — buat database baru dulu
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS nama_db_baru;"
mysql -u root -p nama_db_baru < backup.sql

# Restore file terkompresi
gunzip -c backup.sql.gz | mysql -u root -p nama_db
```

---

## 📤 Export & Import CSV dari Dalam MySQL

### Export ke CSV
```sql
SELECT * FROM produk
INTO OUTFILE '/tmp/produk.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

### Export dengan Header Kolom
```sql
SELECT 'id', 'nama', 'harga'   -- header manual
UNION ALL
SELECT id_produk, nama, harga
FROM produk
INTO OUTFILE '/tmp/produk_header.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

### Import CSV
```sql
LOAD DATA LOCAL INFILE '/tmp/produk.csv'
INTO TABLE produk
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

---

## ⚙️ Opsi mysqldump Penting

| Opsi | Fungsi |
|---|---|
| `--single-transaction` | Backup InnoDB tanpa lock tabel (WAJIB untuk produksi) |
| `--routines` | Sertakan stored procedure & function |
| `--triggers` | Sertakan trigger |
| `--events` | Sertakan event scheduler |
| `--no-data` | Schema saja |
| `--no-create-info` | Data saja |
| `--all-databases` | Semua database |
| `--databases db1 db2` | Database pilihan |
| `-h host -P port` | Backup dari remote server |

---

## 🤖 Shell Script Backup Otomatis

File `backup_restore.sql` berisi contoh shell script `.sh` yang bisa dijadwalkan dengan **cron job** untuk backup otomatis setiap malam:

```bash
# Contoh cron: backup setiap hari pukul 02:00
0 2 * * * /path/to/backup_otomatis.sh

# Script akan:
# 1. Backup database dengan kompresi
# 2. Catat log hasil backup
# 3. Hapus otomatis file backup > 7 hari (rotasi)
```

---

## 📊 Strategi Backup yang Direkomendasikan

| Frekuensi | Tipe | Retensi |
|---|---|---|
| **Harian** (malam) | Full backup + kompresi | Simpan 7 hari |
| **Mingguan** | Full backup + arsip | Simpan 4 minggu |
| **Bulanan** | Full backup + arsip panjang | Simpan 12 bulan |

---

## 🗂️ Isi File `backup_restore.sql`

| Section | Isi |
|---|---|
| 1 | Setup database demo untuk latihan |
| 2 | Semua variasi perintah `mysqldump` (dalam komentar) |
| 3 | Perintah restore dari terminal (dalam komentar) |
| 4 | `SELECT INTO OUTFILE` dan `LOAD DATA` dari dalam MySQL |
| 5 | Template shell script backup otomatis + rotasi (dalam komentar) |
| 6 | Query pembantu: ukuran DB/tabel, cek variabel, `SHOW PROCESSLIST` |

---

## 🚀 Cara Pakai

```bash
# Jalankan setup database demo
mysql -u root -p < backup_restore.sql

# Coba backup database demo
mysqldump -u root -p backup_demo > backup_demo.sql

# Restore ke database baru
mysql -u root -p -e "CREATE DATABASE backup_test;"
mysql -u root -p backup_test < backup_demo.sql
```