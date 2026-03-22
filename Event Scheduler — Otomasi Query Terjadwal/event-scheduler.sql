-- ============================================================
-- File    : event_scheduler.sql
-- Topik   : Event Scheduler — Otomasi Query Terjadwal
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- Event Scheduler = "cron job" di dalam MySQL.
-- Bisa menjalankan SQL secara otomatis pada waktu tertentu
-- tanpa perlu trigger atau aplikasi eksternal.
-- ============================================================


-- ============================================================
-- SECTION 1: AKTIFKAN EVENT SCHEDULER
-- ============================================================

-- Cek status event scheduler
SHOW VARIABLES LIKE 'event_scheduler';

-- Aktifkan (perlu hak SUPER / SESSION_VARIABLES_ADMIN)
SET GLOBAL event_scheduler = ON;

-- Untuk aktif permanen, tambahkan di my.cnf / my.ini:
-- [mysqld]
-- event_scheduler = ON


-- ============================================================
-- SECTION 2: SETUP DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS event_demo;
USE event_demo;

-- Tabel produk dengan stok
CREATE TABLE IF NOT EXISTS produk (
    id_produk  INT AUTO_INCREMENT PRIMARY KEY,
    nama       VARCHAR(100),
    stok       INT DEFAULT 0,
    harga      INT
);

-- Tabel log aktivitas event
CREATE TABLE IF NOT EXISTS log_event (
    id_log      INT AUTO_INCREMENT PRIMARY KEY,
    nama_event  VARCHAR(100),
    keterangan  TEXT,
    waktu       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel laporan harian (diisi otomatis oleh event)
CREATE TABLE IF NOT EXISTS laporan_harian (
    id_laporan   INT AUTO_INCREMENT PRIMARY KEY,
    tgl_laporan  DATE,
    total_produk INT,
    total_stok   INT,
    dibuat_pada  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel arsip produk habis
CREATE TABLE IF NOT EXISTS arsip_stok_habis (
    id_arsip    INT AUTO_INCREMENT PRIMARY KEY,
    id_produk   INT,
    nama        VARCHAR(100),
    tgl_arsip   DATE,
    arsip_pada  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO produk (nama, stok, harga) VALUES
    ('Laptop Ultra',    5, 14000000),
    ('Mouse Wireless',  0,   185000),  -- stok habis
    ('Keyboard Mekanikal', 3, 650000),
    ('Headphone Pro',   0,   950000),  -- stok habis
    ('Buku SQL',       15,    95000),
    ('Meja Belajar',    2,  1800000);


-- ============================================================
-- SECTION 3: EVENT SATU KALI (ONE-TIME EVENT)
-- ============================================================
-- Dijalankan sekali pada waktu tertentu, lalu terhapus otomatis.

-- 3.1 Event: catat log 1 menit dari sekarang
CREATE EVENT IF NOT EXISTS ev_log_sekali
ON SCHEDULE AT NOW() + INTERVAL 1 MINUTE
ON COMPLETION NOT PRESERVE   -- hapus event setelah selesai
DO
    INSERT INTO log_event (nama_event, keterangan)
    VALUES ('ev_log_sekali', 'Event one-time berhasil dijalankan');

-- 3.2 Event: reset stok demo pada waktu tertentu
CREATE EVENT IF NOT EXISTS ev_reset_stok_demo
ON SCHEDULE AT '2025-12-31 23:59:00'
ON COMPLETION NOT PRESERVE
DO
    UPDATE produk SET stok = 10 WHERE stok = 0;


-- ============================================================
-- SECTION 4: EVENT BERULANG (RECURRING EVENT)
-- ============================================================

-- 4.1 Event: catat jumlah produk setiap hari pukul 00:00
CREATE EVENT IF NOT EXISTS ev_laporan_harian
ON SCHEDULE EVERY 1 DAY
STARTS '2025-06-12 00:00:00'
ON COMPLETION PRESERVE       -- event TIDAK terhapus setelah selesai
DO
    INSERT INTO laporan_harian (tgl_laporan, total_produk, total_stok)
    SELECT CURDATE(), COUNT(*), SUM(stok)
    FROM produk;

-- 4.2 Event: arsipkan produk stok habis setiap minggu (Senin pukul 01:00)
CREATE EVENT IF NOT EXISTS ev_arsip_stok_habis
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-06-16 01:00:00'  -- mulai Senin pertama
ON COMPLETION PRESERVE
DO BEGIN
    -- Insert ke tabel arsip
    INSERT INTO arsip_stok_habis (id_produk, nama, tgl_arsip)
    SELECT id_produk, nama, CURDATE()
    FROM produk
    WHERE stok = 0;

    -- Log aktivitas
    INSERT INTO log_event (nama_event, keterangan)
    VALUES ('ev_arsip_stok_habis',
            CONCAT('Diarsipkan ', ROW_COUNT(), ' produk stok habis'));
END;

-- 4.3 Event: tambah stok otomatis setiap bulan (tanggal 1)
CREATE EVENT IF NOT EXISTS ev_restock_bulanan
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-07-01 06:00:00'
ON COMPLETION PRESERVE
DO BEGIN
    UPDATE produk SET stok = stok + 20 WHERE stok < 5;

    INSERT INTO log_event (nama_event, keterangan)
    VALUES ('ev_restock_bulanan', 'Restock otomatis produk stok < 5');
END;

-- 4.4 Event: bersihkan log lama setiap hari (hapus log > 30 hari)
CREATE EVENT IF NOT EXISTS ev_bersihkan_log
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
ON COMPLETION PRESERVE
DO
    DELETE FROM log_event
    WHERE waktu < NOW() - INTERVAL 30 DAY;


-- ============================================================
-- SECTION 5: MANAJEMEN EVENT
-- ============================================================

-- 5.1 Lihat semua event di database ini
SELECT
    event_name,
    event_type,
    execute_at,
    interval_value,
    interval_field,
    status,
    last_executed
FROM information_schema.events
WHERE event_schema = 'event_demo';

-- Atau lebih singkat:
SHOW EVENTS FROM event_demo;

-- 5.2 Lihat definisi event
SHOW CREATE EVENT ev_laporan_harian;

-- 5.3 Nonaktifkan event sementara
ALTER EVENT ev_laporan_harian DISABLE;

-- 5.4 Aktifkan kembali
ALTER EVENT ev_laporan_harian ENABLE;

-- 5.5 Ubah jadwal event
ALTER EVENT ev_laporan_harian
ON SCHEDULE EVERY 1 DAY
STARTS '2025-06-12 02:00:00';

-- 5.6 Rename event
ALTER EVENT ev_log_sekali RENAME TO ev_log_oneshot;

-- 5.7 Hapus event
DROP EVENT IF EXISTS ev_log_sekali;
DROP EVENT IF EXISTS ev_reset_stok_demo;


-- ============================================================
-- SECTION 6: SIMULASI — JALANKAN MANUAL
-- ============================================================
-- Untuk testing tanpa menunggu jadwal, panggil langsung isinya.

-- Simulasi laporan harian
INSERT INTO laporan_harian (tgl_laporan, total_produk, total_stok)
SELECT CURDATE(), COUNT(*), SUM(stok)
FROM produk;

SELECT * FROM laporan_harian;

-- Simulasi arsip stok habis
INSERT INTO arsip_stok_habis (id_produk, nama, tgl_arsip)
SELECT id_produk, nama, CURDATE()
FROM produk WHERE stok = 0;

SELECT * FROM arsip_stok_habis;

-- Cek semua log
SELECT * FROM log_event ORDER BY waktu DESC;