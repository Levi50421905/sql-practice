# 📦 Studi Kasus: Sistem Inventori & Gudang

**Topik:** Studi Kasus — Database Manajemen Stok Multi-Gudang  
**Database:** MariaDB / MySQL  
**Author:** Muhammad Alfarezzi Fallevi · 4IA17 · 50421905

---

## 🧠 Deskripsi Kasus

Sebuah perusahaan distribusi memiliki beberapa gudang di berbagai kota. Mereka perlu sistem database untuk:
- Memantau stok produk di setiap gudang
- Mencatat setiap pergerakan stok (masuk, keluar, transfer antar gudang)
- Mengelola Purchase Order ke supplier
- Mendapat alert otomatis ketika stok mendekati batas minimum

Studi kasus ini melatih `UNIQUE KEY` kombinasi kolom, `ENUM`, pivot dengan `SUM CASE`, alert dengan `HAVING`, dan running total dengan Window Function.

---

## 🗂️ Struktur Database

```
inventori_db
│
├── Supplier          → data pemasok/vendor
├── Kategori          → kategori produk (Elektronik, Furniture, dll)
│
├── Produk            → master produk (FK → Kategori, Supplier)
│     ↓
├── Stok              → stok per produk per gudang (UNIQUE: produk+gudang)
│     └── Mutasi_Stok → log setiap pergerakan stok (MASUK/KELUAR/TRANSFER)
│
├── Gudang            → daftar gudang + lokasi + kapasitas
│
├── Purchase_Order    → PO ke supplier (header)
└── Detail_PO         → item yang dipesan per PO
```

---

## 📋 Skema Tabel

### `Produk`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_produk | VARCHAR(10) | PRIMARY KEY |
| nama_produk | VARCHAR(200) | Nama produk |
| id_kategori | VARCHAR(10) | FK → Kategori |
| id_supplier | VARCHAR(10) | FK → Supplier |
| satuan | VARCHAR(20) | Unit, Lusin, Rim, dll |
| harga_beli | INT | Harga dari supplier |
| harga_jual | INT | Harga jual ke konsumen |
| stok_minimum | INT | Batas alert restock |

### `Stok`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_stok | INT AUTO_INCREMENT | PRIMARY KEY |
| id_produk | VARCHAR(10) | FK → Produk |
| id_gudang | VARCHAR(10) | FK → Gudang |
| jumlah | INT | Jumlah stok saat ini |
| — | `UNIQUE KEY (id_produk, id_gudang)` | **Satu produk max 1 baris per gudang** |

### `Mutasi_Stok`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_mutasi | INT AUTO_INCREMENT | PRIMARY KEY |
| id_produk | VARCHAR(10) | FK → Produk |
| id_gudang | VARCHAR(10) | FK → Gudang |
| jenis | ENUM | `MASUK`, `KELUAR`, `TRANSFER` |
| jumlah | INT | Jumlah yang bergerak |
| keterangan | VARCHAR(255) | Keterangan transaksi |
| tgl_mutasi | DATE | Tanggal mutasi |

---

## 🆕 Fitur SQL yang Dipelajari

### UNIQUE KEY Kombinasi Kolom
Memastikan tidak ada duplikat kombinasi produk + gudang:
```sql
UNIQUE KEY uk_produk_gudang (id_produk, id_gudang)
-- Produk A di Gudang 1 → boleh hanya 1 baris
-- Jika INSERT produk yang sama ke gudang yang sama → ERROR
-- Untuk update stok pakai: INSERT ... ON DUPLICATE KEY UPDATE
```

### Pivot dengan SUM CASE
Menampilkan stok per gudang dalam format kolom (horizontal):
```sql
SELECT
    p.nama_produk,
    SUM(CASE WHEN s.id_gudang = 'GDG01' THEN s.jumlah ELSE 0 END) AS Jakarta,
    SUM(CASE WHEN s.id_gudang = 'GDG02' THEN s.jumlah ELSE 0 END) AS Bandung,
    SUM(CASE WHEN s.id_gudang = 'GDG03' THEN s.jumlah ELSE 0 END) AS Surabaya,
    SUM(s.jumlah) AS total
FROM Produk p JOIN Stok s ON p.id_produk = s.id_produk
GROUP BY p.id_produk, p.nama_produk;
```

### Alert Restock dengan HAVING
Produk yang perlu di-restock:
```sql
SELECT p.nama_produk, p.stok_minimum, SUM(s.jumlah) AS stok_saat_ini,
       (p.stok_minimum - SUM(s.jumlah)) AS kekurangan
FROM Produk p
LEFT JOIN Stok s ON p.id_produk = s.id_produk
GROUP BY p.id_produk, p.nama_produk, p.stok_minimum
HAVING SUM(s.jumlah) <= p.stok_minimum  -- filter setelah GROUP BY
ORDER BY kekurangan DESC;
```

### Running Total Mutasi (CTE + Window Function)
```sql
WITH mutasi_masuk AS (
    SELECT p.nama_produk, ms.tgl_mutasi, ms.jumlah
    FROM Mutasi_Stok ms JOIN Produk p ON ms.id_produk = p.id_produk
    WHERE ms.jenis = 'MASUK'
)
SELECT nama_produk, tgl_mutasi, jumlah,
    SUM(jumlah) OVER (
        PARTITION BY nama_produk
        ORDER BY tgl_mutasi
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS kumulatif_masuk
FROM mutasi_masuk;
```

---

## 💻 Query Analitik dalam File

| Query | Teknik SQL |
|---|---|
| Stok total + status menipis | `SUM` + `CASE WHEN` |
| Pivot stok per gudang | `SUM CASE` per kolom |
| Riwayat mutasi stok | JOIN + `ORDER BY tgl DESC` |
| Nilai inventori per gudang | `SUM(stok × harga_beli)` |
| Total nilai Purchase Order | JOIN + `SUM` |
| Produk perlu restock + info supplier | JOIN + `HAVING` |
| Running total mutasi masuk | CTE + `SUM() OVER()` |

---

## 🗂️ Isi File `inventori.sql`

| Section | Isi |
|---|---|
| 1 | DDL — 7 tabel dengan UNIQUE KEY, ENUM, semua FK |
| 2 | INSERT — supplier, kategori, produk, gudang, stok, mutasi, PO |
| 3 | 7 query analitik termasuk pivot dan running total |

---

## 🚀 Cara Pakai

```bash
mysql -u root -p < inventori.sql
```