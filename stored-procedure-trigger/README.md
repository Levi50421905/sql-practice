# ⚙️ Stored Procedure & Trigger

> Materi kuliah — Insinyur Data Madya  
> Topik: Stored Procedure dan Trigger dalam SQL

---

## 📁 Isi Folder

```
stored-procedure-trigger/
├── README.md              ← kamu lagi baca ini
├── stored-procedure.sql   ← 2 stored procedure studi kasus perpustakaan
└── trigger.sql            ← trigger studi kasus penjualan makanan + perpustakaan
```

---

## 🛠️ Database yang Digunakan

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)

---

## 📚 Stored Procedure

Stored Procedure adalah sekumpulan perintah SQL yang disimpan dan dapat dipanggil ulang.

### Sintaks Dasar
```sql
DELIMITER //
CREATE PROCEDURE NamaProcedure(IN param1 INT, OUT param2 VARCHAR(50))
BEGIN
    -- logika SQL di sini
END //
DELIMITER ;

-- Memanggil stored procedure
CALL NamaProcedure(nilai1, @output);
```

### Jenis Parameter
| Jenis | Fungsi |
|---|---|
| `IN` | Menerima nilai input dari pemanggil |
| `OUT` | Mengembalikan nilai ke pemanggil |
| `INOUT` | Menerima sekaligus mengembalikan nilai |

### Stored Procedure dalam File Ini
| Nama | Fungsi |
|---|---|
| `GetBorrowedBooksByMonth` | Daftar buku dipinjam berdasarkan bulan & tahun |
| `CheckBookStockAndAlert` | Cek stok buku rendah & simpan ke tabel alert |

```sql
-- Contoh pemanggilan
CALL GetBorrowedBooksByMonth(1, 2024);   -- buku dipinjam Januari 2024
CALL CheckBookStockAndAlert();            -- cek & catat stok rendah
```

---

## ⚡ Trigger

Trigger adalah perintah SQL yang berjalan **otomatis** saat terjadi `INSERT`, `UPDATE`, atau `DELETE` pada tabel.

### Sintaks Dasar
```sql
DELIMITER //
CREATE TRIGGER nama_trigger
AFTER INSERT ON nama_tabel
FOR EACH ROW
BEGIN
    -- aksi otomatis di sini
END //
DELIMITER ;
```

### Waktu Eksekusi
| Waktu | Keterangan |
|---|---|
| `BEFORE` | Dijalankan sebelum operasi |
| `AFTER` | Dijalankan setelah operasi |

### Trigger dalam File Ini

**Database PenjualanMakanan:**
| Nama Trigger | Event | Fungsi |
|---|---|---|
| `trg_penjualan_insert` | AFTER INSERT | Catat penjualan baru ke log |
| `trg_penjualan_update` | AFTER UPDATE | Catat perubahan data ke log |
| `trg_penjualan_delete` | BEFORE DELETE | Catat penghapusan data ke log |

**Database Perpustakaan:**
| Nama Trigger | Event | Fungsi |
|---|---|---|
| `after_borrow_insert` | AFTER INSERT | Kurangi stok buku saat dipinjam |
| `after_borrow_update` | AFTER UPDATE | Tambah stok saat buku dikembalikan |

---

## 🚀 Cara Menjalankan

```bash
# Login MariaDB/MySQL
mysql -u root -p

# Jalankan stored procedure (pastikan DB Perpustakaan sudah ada)
source stored-procedure.sql

# Jalankan trigger
source trigger.sql
```

---

## 🔍 Perbedaan Stored Procedure vs Trigger

| | Stored Procedure | Trigger |
|---|---|---|
| **Dijalankan** | Dipanggil manual dengan `CALL` | Otomatis saat ada perubahan data |
| **Parameter** | Bisa menerima IN/OUT/INOUT | Tidak ada parameter |
| **Kontrol** | Bisa dipanggil kapan saja | Hanya aktif saat event terjadi |
| **Kegunaan** | Logika bisnis kompleks | Audit, validasi, integritas data |