# 🗄️ Membuat dan Menguji Basis Data

> Materi kuliah — Insinyur Data Madya  
> Topik: Membuat & Menguji Database menggunakan SQL

---

## 📁 Isi Folder

```
membuat-menguji-db/
├── README.md       ← kamu lagi baca ini
├── schema.sql      ← membuat database, tabel, insert, update
└── queries.sql     ← pengujian database (validasi, join, indeks, transaksi)
```

---

## 🛠️ Database yang Digunakan

![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)

---

## 📚 Konsep yang Dipelajari

### Membuat Database
| Perintah | Fungsi |
|---|---|
| `CREATE DATABASE` | Membuat database baru |
| `CREATE TABLE` | Membuat tabel |
| `PRIMARY KEY` | Kunci utama — unik, tidak boleh NULL |
| `FOREIGN KEY` | Kunci asing — relasi antar tabel |
| `CREATE INDEX` | Membuat indeks untuk mempercepat query |
| `INSERT INTO` | Menambah data |
| `UPDATE` | Mengubah data |
| `DELETE` | Menghapus data |
| `GRANT` | Memberi hak akses pengguna |

### Menguji Database
| Teknik | Alat |
|---|---|
| Validasi Skema | `SHOW TABLES`, `DESCRIBE`, `INFORMATION_SCHEMA` |
| Pengujian Data | `SELECT * WHERE kondisi` |
| Pengujian Indeks | `EXPLAIN` |
| Pengujian Transaksi | `START TRANSACTION`, `COMMIT`, `ROLLBACK` |
| Normalisasi Check | `GROUP BY ... HAVING COUNT(*) > 1` |

---

## 🏗️ Struktur Database Perpustakaan

```
Buku ──────────────┐
                   ↓
Anggota ──────► Peminjaman
```

3 tabel: `Buku`, `Anggota`, `Peminjaman`  
Relasi: `Peminjaman` memiliki foreign key ke `Buku` dan `Anggota`

---

## 🔑 Konsep Primary Key & Foreign Key

**Primary Key** — mengidentifikasi setiap baris secara unik:
```sql
CREATE TABLE Buku (
    ID_Buku INT PRIMARY KEY AUTO_INCREMENT,
    Judul   VARCHAR(255) NOT NULL
);
```

**Foreign Key** — menghubungkan dua tabel:
```sql
CREATE TABLE Peminjaman (
    ID_Buku    INT,
    ID_Anggota INT,
    FOREIGN KEY (ID_Buku)    REFERENCES Buku(ID_Buku),
    FOREIGN KEY (ID_Anggota) REFERENCES Anggota(ID_Anggota)
);
```

---

## 🚀 Cara Menjalankan

```bash
# Login ke MariaDB
mysql -u root -p

# Jalankan schema (membuat & isi database)
source schema.sql

# Jalankan query pengujian
source queries.sql
```

---

## 📝 Normalisasi Database

| Bentuk | Aturan |
|---|---|
| **1NF** | Hapus grup data berulang di tabel |
| **2NF** | Setiap kolom bergantung penuh pada primary key |
| **3NF** | Kolom non-key tidak bergantung pada kolom non-key lain |

---

## 🔒 Jenis Data Integrity

| Jenis | Penjelasan |
|---|---|
| **Entity Integrity** | Primary key harus unik dan tidak NULL |
| **Referential Integrity** | Foreign key harus cocok dengan primary key di tabel lain |
| **Domain Integrity** | Nilai kolom harus sesuai tipe datanya |
| **User-defined Integrity** | Aturan bisnis yang ditentukan sendiri |