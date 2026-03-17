# 📦 Sesi 01 - Integrasi Data

> Tugas Harian - Insinyur Data Madya  
> Rabu, 11 Juni 2025

---

## 📋 Deskripsi

Latihan integrasi data dengan cara menggabungkan file `.csv` ke dalam tabel database menggunakan perintah `LOAD DATA LOCAL INFILE` di MariaDB.

---

## 📁 Isi Folder

```
integrasi-data/
├── README.md           ← kamu lagi baca ini
├── schema.sql          ← buat tabel + load data dari CSV
└── integrasiData.csv   ← data barang (delimiter: titik koma)
```

---

## 🛠️ Database yang Digunakan

![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)

---

## 📊 Data Barang

| id_barang | nm_barang          | merk    | ukuran | stok | harga  |
|-----------|--------------------|---------|--------|------|--------|
| 1         | Roti maryam coklat | Takaji  | 350 gr | 150  | 25.000 |
| 2         | Roti maryam keju   | Takaji  | 350 gr | 32   | 25.000 |
| 3         | Shoe string        | Mydibel | 1 kg   | 50   | 28.000 |

---

## 🚀 Cara Menjalankan

**1. Buka MariaDB / MySQL**
```bash
mysql -u root -p
```

**2. Jalankan schema**
```bash
source schema.sql
```

**3. Atau manual step by step**
```sql
CREATE DATABASE sesi2;
USE sesi2;

-- Buat tabel barang
CREATE TABLE barang (
    id_barang  INT PRIMARY KEY AUTO_INCREMENT,
    nm_barang  VARCHAR(100),
    merk       VARCHAR(50),
    ukuran     VARCHAR(20),
    stok       INT,
    harga      DECIMAL(10,2)
);

-- Load dari CSV
LOAD DATA LOCAL INFILE 'integrasiData.csv'
    INTO TABLE barang
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (id_barang, nm_barang, merk, ukuran, stok, harga);

-- Cek hasilnya
SELECT * FROM barang;
```

---

## 💡 Konsep yang Dipelajari

- Integrasi data menggunakan file `.csv`
- Delimiter (tanda pemisah) pada file CSV → titik koma `;`
- Perintah `LOAD DATA LOCAL INFILE` di MariaDB
- Format angka ID dengan leading zeros (`0000001`)

---

## 📝 Catatan

- Delimiter file CSV bisa dicek dengan membuka file menggunakan **text editor** (Notepad, VSCode)
- Gunakan `IGNORE 1 ROWS` untuk melewati baris header
- Pastikan path file CSV sesuai dengan lokasi file di komputer kamu