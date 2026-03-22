# ⏰ Event Scheduler

**Topik:** Event Scheduler — Otomasi Query SQL Terjadwal  
**Database:** MariaDB / MySQL  
**Author:** Muhammad Alfarezzi Fallevi · 4IA17 · 50421905

---

## 🧠 Apa itu Event Scheduler?

Event Scheduler adalah fitur MySQL/MariaDB yang memungkinkan kita menjalankan perintah SQL secara **otomatis pada waktu tertentu** — seperti cron job, tapi langsung di dalam database tanpa perlu aplikasi atau script eksternal.

### Kapan Event Scheduler Berguna?
- Generate laporan harian otomatis setiap tengah malam
- Bersihkan data log lama setiap minggu
- Kirim reminder atau update status secara berkala
- Restock stok produk secara otomatis setiap bulan
- Arsipkan data yang sudah kadaluarsa

---

## 📖 Konsep Dasar

### Aktifkan Event Scheduler
Event Scheduler tidak aktif secara default. Harus diaktifkan dulu:

```sql
-- Cek status
SHOW VARIABLES LIKE 'event_scheduler';

-- Aktifkan sementara (hilang setelah restart)
SET GLOBAL event_scheduler = ON;

-- Aktifkan permanen → tambahkan di my.cnf:
-- [mysqld]
-- event_scheduler = ON
```

### Jenis Event

| Tipe | Kapan Jalan | Cocok Untuk |
|---|---|---|
| **One-Time** | Satu kali pada waktu tertentu | Migrasi data, reset sekali |
| **Recurring** | Berulang sesuai interval | Laporan, cleanup, restock |

---

## 📝 Sintaks Event

### Struktur Dasar
```sql
CREATE EVENT [IF NOT EXISTS] nama_event
ON SCHEDULE [jadwal]
[ON COMPLETION [NOT] PRESERVE]
[ENABLE | DISABLE]
DO
    [perintah SQL];
```

- `ON COMPLETION PRESERVE` → event tetap ada setelah selesai (untuk recurring)
- `ON COMPLETION NOT PRESERVE` → event otomatis terhapus setelah jalan (untuk one-time)

### One-Time Event
```sql
-- Jalan 5 menit dari sekarang
ON SCHEDULE AT NOW() + INTERVAL 5 MINUTE

-- Jalan pada tanggal & waktu tertentu
ON SCHEDULE AT '2025-12-31 23:59:00'
```

### Recurring Event
```sql
ON SCHEDULE EVERY 1 MINUTE
ON SCHEDULE EVERY 1 HOUR   STARTS '2025-06-12 00:00:00'
ON SCHEDULE EVERY 1 DAY    STARTS '2025-06-12 00:00:00'
ON SCHEDULE EVERY 1 WEEK   STARTS '2025-06-16 01:00:00'
ON SCHEDULE EVERY 1 MONTH  STARTS '2025-07-01 06:00:00'
ON SCHEDULE EVERY 6 MONTH
ON SCHEDULE EVERY 1 YEAR
```

### Event dengan Multiple Statement
Jika isi event lebih dari satu perintah, gunakan `BEGIN...END`:

```sql
CREATE EVENT nama_event
ON SCHEDULE EVERY 1 DAY
STARTS '2025-06-12 00:00:00'
ON COMPLETION PRESERVE
DO BEGIN
    -- perintah pertama
    INSERT INTO laporan ...;
    -- perintah kedua
    INSERT INTO log_event ...;
END;
```

---

## 💻 Contoh Event di File

### Laporan Harian Otomatis (setiap hari 00:00)
```sql
CREATE EVENT ev_laporan_harian
ON SCHEDULE EVERY 1 DAY
STARTS '2025-06-12 00:00:00'
ON COMPLETION PRESERVE
DO
    INSERT INTO laporan_harian (tgl_laporan, total_produk, total_stok)
    SELECT CURDATE(), COUNT(*), SUM(stok) FROM produk;
```

### Arsip Stok Habis (setiap Senin 01:00)
```sql
CREATE EVENT ev_arsip_stok_habis
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-06-16 01:00:00'
ON COMPLETION PRESERVE
DO BEGIN
    INSERT INTO arsip_stok_habis (id_produk, nama, tgl_arsip)
    SELECT id_produk, nama, CURDATE() FROM produk WHERE stok = 0;

    INSERT INTO log_event (nama_event, keterangan)
    VALUES ('ev_arsip_stok_habis', CONCAT('Diarsipkan ', ROW_COUNT(), ' produk'));
END;
```

### Bersihkan Log Lama (setiap hari, hapus log > 30 hari)
```sql
CREATE EVENT ev_bersihkan_log
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
ON COMPLETION PRESERVE
DO
    DELETE FROM log_event WHERE waktu < NOW() - INTERVAL 30 DAY;
```

---

## ⚙️ Manajemen Event

```sql
-- Lihat semua event
SHOW EVENTS FROM nama_db;

-- Lihat definisi event
SHOW CREATE EVENT nama_event;

-- Nonaktifkan sementara
ALTER EVENT nama_event DISABLE;

-- Aktifkan kembali
ALTER EVENT nama_event ENABLE;

-- Ubah jadwal
ALTER EVENT nama_event ON SCHEDULE EVERY 1 DAY STARTS '2025-07-01 00:00:00';

-- Rename
ALTER EVENT nama_lama RENAME TO nama_baru;

-- Hapus
DROP EVENT IF EXISTS nama_event;
```

---

## 🗂️ Dataset & Event dalam File

**Database:** `event_demo` — tabel produk, log aktivitas, laporan harian, arsip stok

| Event | Jadwal | Fungsi |
|---|---|---|
| `ev_log_sekali` | 1x, 1 menit dari sekarang | Uji one-time event |
| `ev_laporan_harian` | Setiap hari 00:00 | Insert ringkasan ke `laporan_harian` |
| `ev_arsip_stok_habis` | Setiap Senin 01:00 | Arsipkan produk stok = 0 |
| `ev_restock_bulanan` | Tanggal 1 setiap bulan | Auto-restock produk stok < 5 |
| `ev_bersihkan_log` | Setiap hari | Hapus log > 30 hari |

---

## 🗂️ Isi File `event_scheduler.sql`

| Section | Isi |
|---|---|
| 1 | Aktifkan Event Scheduler + cek status |
| 2 | Setup database + tabel log, laporan, arsip |
| 3 | One-time event |
| 4 | 4 recurring event (harian, mingguan, bulanan) |
| 5 | Manajemen: SHOW, ALTER, DISABLE, ENABLE, DROP |
| 6 | Simulasi manual — jalankan isi event tanpa menunggu jadwal |

---

## 🚀 Cara Pakai

```bash
mysql -u root -p < event_scheduler.sql
```

> **Pastikan:** `SET GLOBAL event_scheduler = ON;` dijalankan terlebih dahulu.