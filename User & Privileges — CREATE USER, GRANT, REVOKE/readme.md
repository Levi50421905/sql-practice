# 🐘 SQL Practice

> Kumpulan latihan & materi SQL dari perjalanan belajar saya sebagai developer.  
> Mencakup studi kasus nyata dari mata kuliah **Insinyur Data Madya**.

<div align="center">

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=database&logoColor=white)

</div>

---

## 📁 Struktur Repo

```
sql-practice/
│
├── 📂 perpustakaan/
│   ├── schema.sql                  ← tabel + seed data perpustakaan
│   └── queries.sql                 ← 17 query latihan (SELECT, JOIN, agregasi)
│
├── 📂 integrasi-data/
│   ├── README.md
│   ├── schema.sql                  ← LOAD DATA dari file CSV ke MariaDB
│   └── integrasiData.csv           ← data barang (delimiter titik koma)
│
├── 📂 membuat-menguji-db/
│   ├── README.md
│   ├── schema.sql                  ← DDL, DML, Foreign Key, Index
│   └── queries.sql                 ← pengujian validasi, JOIN, transaksi, indeks
│
├── 📂 stored-procedure-trigger/
│   ├── README.md
│   ├── stored-procedure.sql        ← 2 stored procedure studi kasus perpustakaan
│   └── trigger.sql                 ← trigger penjualan makanan & perpustakaan
│
├── 📂 membuat-database-engineer/
│   ├── README.md
│   └── engineerl.sql               ← DDL, DML, JOIN — DB manajemen proyek insinyur
│
├── 📂 poliklinik/
│   ├── README.md
│   ├── poliklinik.sql              ← DDL, DML, DQL analitik, LOAD DATA INFILE
│   └── dataKlinik.csv              ← data klinik tambahan (delimiter titik koma)
│
├── 📂 normalisasi/
│   ├── README.md
│   └── normalisasi.sql             ← 0NF → 1NF → 2NF → 3NF (studi kasus seminar)
│
├── 📂 view/
│   ├── README.md
│   └── view.sql                    ← CREATE VIEW, updatable view, WITH CHECK OPTION
│
├── 📂 subquery-cte/
│   ├── README.md
│   └── subquery_cte.sql            ← subquery, derived table, CTE, recursive CTE
│
├── 📂 window-function/
│   ├── README.md
│   └── window_function.sql         ← RANK, ROW_NUMBER, LAG, LEAD, running total
│
├── 📂 user-privileges/
│   ├── README.md
│   └── user_privileges.sql         ← CREATE USER, GRANT, REVOKE, ROLE
│
├── 📂 backup-restore/
│   ├── README.md
│   └── backup_restore.sql          ← mysqldump, restore, export/import CSV, shell script
│
├── 📂 event-scheduler/
│   ├── README.md
│   └── event_scheduler.sql         ← one-time & recurring event, ALTER/DROP EVENT
│
├── 📂 full-text-search/
│   ├── README.md
│   └── full_text_search.sql        ← MATCH AGAINST, boolean mode, FULLTEXT index
│
├── 📂 e-learning/
│   ├── README.md
│   └── elearning.sql               ← studi kasus: mahasiswa, kursus, progress, sertifikat
│
├── 📂 sistem-inventori/
│   ├── README.md
│   └── inventori.sql               ← studi kasus: produk, gudang, stok, mutasi, PO
│
├── 📂 sistem-keuangan/
│   ├── README.md
│   └── keuangan.sql                ← studi kasus: double-entry, jurnal, laba rugi, neraca
│
└── README.md                       ← kamu lagi baca ini
```

---

## 📚 Topik yang Dipelajari

| No | Topik | Status | Folder |
|----|-------|--------|--------|
| 1 | DDL — `CREATE`, `ALTER`, `DROP` | ✅ | `membuat-menguji-db`, `membuat-database-engineer` |
| 2 | DML — `INSERT`, `UPDATE`, `DELETE` | ✅ | `membuat-menguji-db`, `poliklinik` |
| 3 | Query dasar — `SELECT`, `WHERE`, `ORDER BY` | ✅ | `perpustakaan` |
| 4 | JOIN — `INNER JOIN`, `LEFT JOIN` | ✅ | `perpustakaan`, `poliklinik` |
| 5 | Agregasi — `COUNT`, `SUM`, `AVG`, `GROUP BY` | ✅ | `perpustakaan`, `poliklinik` |
| 6 | Integrasi Data — `LOAD DATA INFILE` dari CSV | ✅ | `integrasi-data`, `poliklinik` |
| 7 | Primary Key & Foreign Key | ✅ | `membuat-menguji-db`, `membuat-database-engineer` |
| 8 | Index & Pengujian Query (`EXPLAIN`) | ✅ | `membuat-menguji-db` |
| 9 | Transaksi — `COMMIT`, `ROLLBACK` | ✅ | `membuat-menguji-db` |
| 10 | Stored Procedure — `IN`, `OUT`, `CURSOR` | ✅ | `stored-procedure-trigger` |
| 11 | Trigger — `BEFORE/AFTER INSERT/UPDATE/DELETE` | ✅ | `stored-procedure-trigger` |
| 12 | Junction Table (Many-to-Many) | ✅ | `membuat-database-engineer` |
| 13 | Multi-FK & Query Analitik | ✅ | `poliklinik` |
| 14 | Normalisasi — 1NF, 2NF, 3NF | ✅ | `normalisasi` |
| 15 | VIEW — virtual table, updatable, WITH CHECK OPTION | ✅ | `view` |
| 16 | Subquery & CTE — nested, derived table, recursive | ✅ | `subquery-cte` |
| 17 | Window Function — RANK, LAG/LEAD, running total | ✅ | `window-function` |
| 18 | User & Privileges — `GRANT`, `REVOKE`, Role | ✅ | `user-privileges` |
| 19 | Backup & Restore — `mysqldump`, export CSV | ✅ | `backup-restore` |
| 20 | Event Scheduler — otomasi query terjadwal | ✅ | `event-scheduler` |
| 21 | Full-Text Search — `MATCH AGAINST`, boolean mode | ✅ | `full-text-search` |
| 22 | Studi Kasus: E-Learning | ✅ | `e-learning` |
| 23 | Studi Kasus: Sistem Inventori | ✅ | `sistem-inventori` |
| 24 | Studi Kasus: Sistem Keuangan (double-entry) | ✅ | `sistem-keuangan` |

---

## 🗂️ Ringkasan Per Folder

### 📂 perpustakaan
Latihan SQL dasar dengan studi kasus database perpustakaan. Mencakup tabel `Buku`, `Anggota`, dan `Peminjaman` dengan relasi foreign key.

### 📂 integrasi-data
Latihan mengintegrasikan data dari file `.csv` ke dalam tabel database menggunakan `LOAD DATA LOCAL INFILE` di MariaDB.

### 📂 membuat-menguji-db
Materi lengkap membuat dan menguji basis data: DDL, DML, Primary Key, Foreign Key, Index, Transaksi ACID.

### 📂 stored-procedure-trigger
Stored Procedure dan Trigger untuk studi kasus perpustakaan dan penjualan makanan.

### 📂 membuat-database-engineer
Sistem manajemen proyek insinyur. Junction table Many-to-Many, ALTER TABLE, JOIN multi-tabel.

### 📂 poliklinik
Sistem informasi klinik 6 tabel. DDL, DML, DQL analitik, dan integrasi CSV. Materi Sesi 02 IK-1 s/d IK-4.

### 📂 normalisasi
Proses bertahap 0NF → 1NF → 2NF → 3NF. Identifikasi Partial Dependency dan Transitive Dependency.

### 📂 view
VIEW sebagai tabel virtual: sederhana, JOIN, agregasi, updatable, dan `WITH CHECK OPTION`.

### 📂 subquery-cte
Nested query di `WHERE`/`FROM`/`SELECT`, CTE non-recursive, CTE berantai, dan Recursive CTE (org chart).

### 📂 window-function
`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG/LEAD`, running total, moving average, `NTILE`, `FIRST_VALUE`.

### 📂 user-privileges
DCL: `CREATE USER`, `GRANT`, `REVOKE`, `DROP USER`, Role — manajemen hak akses database.

### 📂 backup-restore
`mysqldump` (berbagai opsi), restore, export/import CSV, shell script backup otomatis + rotasi.

### 📂 event-scheduler
One-time & recurring event: laporan harian otomatis, arsip stok, restock bulanan, cleanup log lama.

### 📂 full-text-search
`MATCH AGAINST` dengan Natural Language, Boolean Mode (`+`, `-`, `*`, `""`), dan Query Expansion.

### 📂 e-learning
Sistem kursus online: mahasiswa, instruktur, enrollment, progress materi, kuis, sertifikat. Fitur kolom `GENERATED`.

### 📂 sistem-inventori
Manajemen stok multi-gudang: produk, supplier, mutasi MASUK/KELUAR/TRANSFER, Purchase Order, alert restock.

### 📂 sistem-keuangan
Double-entry bookkeeping: chart of accounts, jurnal umum, buku besar, neraca saldo, laba rugi, neraca.

---

## 🚀 Cara Pakai

```bash
git clone https://github.com/Levi50421905/sql-practice.git
cd sql-practice
mysql -u root -p
```

```sql
source perpustakaan/schema.sql
source normalisasi/normalisasi.sql
source view/view.sql
source subquery-cte/subquery_cte.sql
source window-function/window_function.sql
source e-learning/elearning.sql
source sistem-inventori/inventori.sql
source sistem-keuangan/keuangan.sql
```

---

## 💡 Contoh Query

```sql
-- Ranking mahasiswa berdasarkan rata-rata nilai kuis (e-learning)
WITH avg_nilai AS (
    SELECT m.nama, AVG(nk.nilai) AS rata_nilai
    FROM Nilai_Kuis nk
    JOIN Enrollment e ON nk.id_enrollment = e.id_enrollment
    JOIN Mahasiswa m  ON e.id_mahasiswa   = m.id_mahasiswa
    GROUP BY m.id_mahasiswa, m.nama
)
SELECT nama, ROUND(rata_nilai, 2),
       RANK() OVER (ORDER BY rata_nilai DESC) AS peringkat
FROM avg_nilai;
```

```sql
-- Produk perlu restock (inventori)
SELECT p.nama_produk, sp.nama AS supplier,
       p.stok_minimum, SUM(s.jumlah) AS stok_saat_ini
FROM Produk p
JOIN Supplier sp ON p.id_supplier = sp.id_supplier
LEFT JOIN Stok s ON p.id_produk   = s.id_produk
GROUP BY p.id_produk, p.nama_produk, sp.nama, p.stok_minimum
HAVING SUM(s.jumlah) <= p.stok_minimum;
```

```sql
-- Laporan laba bersih (keuangan)
SELECT
    SUM(CASE WHEN ka.tipe = 'Pendapatan' THEN saldo ELSE 0 END) AS total_pendapatan,
    SUM(CASE WHEN ka.tipe IN ('Beban','Harga Pokok Penjualan') THEN saldo ELSE 0 END) AS total_beban,
    SUM(CASE WHEN ka.tipe = 'Pendapatan' THEN saldo ELSE 0 END) -
    SUM(CASE WHEN ka.tipe IN ('Beban','Harga Pokok Penjualan') THEN saldo ELSE 0 END) AS laba_bersih
FROM ...;
```

---

## 🙋‍♂️ Tentang Saya

Saya **Muhammad Alfarezzi Fallevi (Levi)**, beginner developer dari 🇮🇩 Indonesia yang sedang belajar menjadi full-stack developer.

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Levi50421905)
[![HackerRank](https://img.shields.io/badge/HackerRank-2EC866?style=for-the-badge&logo=HackerRank&logoColor=white)](https://www.hackerrank.com/levialfarezziar)

---

<div align="center">
  <i>"Learning SQL one query at a time 🚀"</i>
</div>