-- ============================================================
-- File    : view.sql
-- Topik   : VIEW — Virtual Table, Updatable View, View Kompleks
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- VIEW adalah query yang disimpan sebagai "tabel virtual".
-- Setiap kali VIEW dipanggil, query di dalamnya dieksekusi ulang.
-- Manfaat:
--   1. Menyederhanakan query kompleks yang sering dipakai
--   2. Abstraksi — sembunyikan detail tabel dari pengguna
--   3. Keamanan — batasi kolom/baris yang bisa diakses
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP — Database Toko Online
-- ============================================================

CREATE DATABASE IF NOT EXISTS toko_online;
USE toko_online;

CREATE TABLE IF NOT EXISTS Pelanggan (
    id_pelanggan  VARCHAR(10) PRIMARY KEY,
    nama          VARCHAR(100),
    kota          VARCHAR(50),
    email         VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Produk (
    id_produk   VARCHAR(10) PRIMARY KEY,
    nama_produk VARCHAR(100),
    kategori    VARCHAR(50),
    harga       INT,
    stok        INT
);

CREATE TABLE IF NOT EXISTS Pesanan (
    id_pesanan    VARCHAR(10) PRIMARY KEY,
    id_pelanggan  VARCHAR(10),
    tanggal       DATE,
    status        VARCHAR(20),  -- Pending, Diproses, Dikirim, Selesai
    FOREIGN KEY (id_pelanggan) REFERENCES Pelanggan(id_pelanggan)
);

CREATE TABLE IF NOT EXISTS Detail_Pesanan (
    id_detail    INT AUTO_INCREMENT PRIMARY KEY,
    id_pesanan   VARCHAR(10),
    id_produk    VARCHAR(10),
    jumlah       INT,
    harga_satuan INT,
    FOREIGN KEY (id_pesanan) REFERENCES Pesanan(id_pesanan),
    FOREIGN KEY (id_produk)  REFERENCES Produk(id_produk)
);

-- Seed data
INSERT INTO Pelanggan VALUES
    ('C001', 'Andi Saputra',  'Jakarta',   'andi@email.com'),
    ('C002', 'Budi Santoso',  'Bandung',   'budi@email.com'),
    ('C003', 'Citra Dewi',    'Surabaya',  'citra@email.com'),
    ('C004', 'Dian Pratama',  'Jakarta',   'dian@email.com'),
    ('C005', 'Eka Wahyuni',   'Medan',     'eka@email.com');

INSERT INTO Produk VALUES
    ('P001', 'Laptop Pro 14',   'Elektronik', 12500000, 15),
    ('P002', 'Mouse Wireless',  'Elektronik',   185000, 80),
    ('P003', 'Keyboard Mekanikal','Elektronik', 650000, 40),
    ('P004', 'Meja Belajar',    'Furniture',  1800000, 10),
    ('P005', 'Kursi Ergonomis', 'Furniture',  2300000,  8),
    ('P006', 'Buku SQL Dasar',  'Buku',         95000, 50),
    ('P007', 'Buku Clean Code', 'Buku',        115000, 35);

INSERT INTO Pesanan VALUES
    ('ORD001', 'C001', '2025-01-10', 'Selesai'),
    ('ORD002', 'C002', '2025-01-15', 'Selesai'),
    ('ORD003', 'C001', '2025-02-03', 'Selesai'),
    ('ORD004', 'C003', '2025-02-20', 'Dikirim'),
    ('ORD005', 'C004', '2025-03-05', 'Diproses'),
    ('ORD006', 'C005', '2025-03-10', 'Pending'),
    ('ORD007', 'C002', '2025-03-12', 'Diproses');

INSERT INTO Detail_Pesanan (id_pesanan, id_produk, jumlah, harga_satuan) VALUES
    ('ORD001', 'P001', 1, 12500000),
    ('ORD001', 'P002', 2,   185000),
    ('ORD002', 'P003', 1,   650000),
    ('ORD002', 'P006', 2,    95000),
    ('ORD003', 'P002', 1,   185000),
    ('ORD003', 'P004', 1,  1800000),
    ('ORD004', 'P005', 1,  2300000),
    ('ORD004', 'P007', 3,   115000),
    ('ORD005', 'P001', 1, 12500000),
    ('ORD006', 'P006', 5,    95000),
    ('ORD007', 'P003', 2,   650000);


-- ============================================================
-- SECTION 2: VIEW SEDERHANA
-- ============================================================

-- 2.1 View: daftar produk elektronik saja
CREATE OR REPLACE VIEW v_produk_elektronik AS
SELECT id_produk, nama_produk, harga, stok
FROM Produk
WHERE kategori = 'Elektronik';

SELECT * FROM v_produk_elektronik;

-- 2.2 View: pelanggan dari Jakarta saja
CREATE OR REPLACE VIEW v_pelanggan_jakarta AS
SELECT id_pelanggan, nama, email
FROM Pelanggan
WHERE kota = 'Jakarta';

SELECT * FROM v_pelanggan_jakarta;

-- 2.3 View: pesanan yang belum selesai
CREATE OR REPLACE VIEW v_pesanan_aktif AS
SELECT id_pesanan, id_pelanggan, tanggal, status
FROM Pesanan
WHERE status != 'Selesai'
ORDER BY tanggal;

SELECT * FROM v_pesanan_aktif;


-- ============================================================
-- SECTION 3: VIEW DENGAN JOIN
-- ============================================================

-- 3.1 View: rekap pesanan lengkap (JOIN Pesanan + Pelanggan)
CREATE OR REPLACE VIEW v_pesanan_lengkap AS
SELECT
    ps.id_pesanan,
    pl.nama        AS nama_pelanggan,
    pl.kota,
    ps.tanggal,
    ps.status
FROM Pesanan ps
JOIN Pelanggan pl ON ps.id_pelanggan = pl.id_pelanggan;

SELECT * FROM v_pesanan_lengkap;

-- 3.2 View: detail transaksi per produk
CREATE OR REPLACE VIEW v_detail_transaksi AS
SELECT
    dp.id_pesanan,
    pr.nama_produk,
    pr.kategori,
    dp.jumlah,
    dp.harga_satuan,
    (dp.jumlah * dp.harga_satuan) AS subtotal
FROM Detail_Pesanan dp
JOIN Produk pr ON dp.id_produk = pr.id_produk;

SELECT * FROM v_detail_transaksi;

-- 3.3 View: ringkasan nilai per pesanan (total bayar)
CREATE OR REPLACE VIEW v_total_per_pesanan AS
SELECT
    ps.id_pesanan,
    pl.nama              AS nama_pelanggan,
    ps.tanggal,
    ps.status,
    SUM(dp.jumlah * dp.harga_satuan) AS total_bayar
FROM Pesanan ps
JOIN Pelanggan pl     ON ps.id_pelanggan = pl.id_pelanggan
JOIN Detail_Pesanan dp ON ps.id_pesanan  = dp.id_pesanan
GROUP BY ps.id_pesanan, pl.nama, ps.tanggal, ps.status;

SELECT * FROM v_total_per_pesanan ORDER BY total_bayar DESC;


-- ============================================================
-- SECTION 4: VIEW DENGAN AGREGASI
-- ============================================================

-- 4.1 View: total belanja per pelanggan
CREATE OR REPLACE VIEW v_total_belanja_pelanggan AS
SELECT
    pl.id_pelanggan,
    pl.nama,
    pl.kota,
    COUNT(DISTINCT ps.id_pesanan)        AS jumlah_pesanan,
    SUM(dp.jumlah * dp.harga_satuan)     AS total_belanja
FROM Pelanggan pl
LEFT JOIN Pesanan ps        ON pl.id_pelanggan = ps.id_pelanggan
LEFT JOIN Detail_Pesanan dp ON ps.id_pesanan   = dp.id_pesanan
GROUP BY pl.id_pelanggan, pl.nama, pl.kota;

SELECT * FROM v_total_belanja_pelanggan ORDER BY total_belanja DESC;

-- 4.2 View: produk terlaris (berdasarkan total unit terjual)
CREATE OR REPLACE VIEW v_produk_terlaris AS
SELECT
    pr.id_produk,
    pr.nama_produk,
    pr.kategori,
    pr.harga,
    SUM(dp.jumlah)                   AS total_terjual,
    SUM(dp.jumlah * dp.harga_satuan) AS total_revenue
FROM Produk pr
LEFT JOIN Detail_Pesanan dp ON pr.id_produk = dp.id_produk
GROUP BY pr.id_produk, pr.nama_produk, pr.kategori, pr.harga;

SELECT * FROM v_produk_terlaris ORDER BY total_terjual DESC;

-- 4.3 View: rekap penjualan per kategori
CREATE OR REPLACE VIEW v_rekap_kategori AS
SELECT
    pr.kategori,
    COUNT(DISTINCT dp.id_pesanan)    AS jumlah_transaksi,
    SUM(dp.jumlah)                   AS total_unit,
    SUM(dp.jumlah * dp.harga_satuan) AS total_revenue
FROM Detail_Pesanan dp
JOIN Produk pr ON dp.id_produk = pr.id_produk
GROUP BY pr.kategori;

SELECT * FROM v_rekap_kategori ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION 5: QUERY DI ATAS VIEW (VIEW AS SUBQUERY)
-- ============================================================

-- 5.1 Dari v_total_belanja_pelanggan → ambil hanya pelanggan VIP (belanja > 5jt)
SELECT nama, kota, total_belanja
FROM v_total_belanja_pelanggan
WHERE total_belanja > 5000000
ORDER BY total_belanja DESC;

-- 5.2 Dari v_produk_terlaris → produk yang belum pernah terjual
SELECT id_produk, nama_produk, kategori
FROM v_produk_terlaris
WHERE total_terjual IS NULL OR total_terjual = 0;

-- 5.3 Gabung dua view: pesanan aktif + total bayarnya
SELECT
    pa.id_pesanan,
    pa.id_pelanggan,
    pa.status,
    tp.total_bayar
FROM v_pesanan_aktif pa
JOIN v_total_per_pesanan tp ON pa.id_pesanan = tp.id_pesanan
ORDER BY tp.total_bayar DESC;


-- ============================================================
-- SECTION 6: UPDATABLE VIEW
-- ============================================================
-- View yang hanya dari 1 tabel tanpa agregasi bisa di-UPDATE/INSERT.

-- 6.1 Update data melalui view (ubah stok produk elektronik)
UPDATE v_produk_elektronik
SET stok = stok - 1
WHERE id_produk = 'P001';

-- Cek perubahan
SELECT id_produk, nama_produk, stok FROM Produk WHERE id_produk = 'P001';

-- 6.2 Insert data baru melalui view (otomatis masuk tabel Produk + kategori = Elektronik)
-- Catatan: INSERT via VIEW hanya bekerja jika VIEW punya WITH CHECK OPTION
-- atau kolom yang tidak ada di VIEW punya DEFAULT / nullable.


-- ============================================================
-- SECTION 7: WITH CHECK OPTION
-- ============================================================
-- Memastikan INSERT/UPDATE via VIEW tidak melanggar kondisi WHERE view.

CREATE OR REPLACE VIEW v_stok_aman AS
SELECT id_produk, nama_produk, kategori, harga, stok
FROM Produk
WHERE stok > 0
WITH CHECK OPTION;
-- Jika ada UPDATE yang membuat stok = 0 atau negatif → akan ditolak

-- Test: ini akan berhasil (stok masih > 0)
UPDATE v_stok_aman SET stok = 5 WHERE id_produk = 'P004';

-- Test: ini akan GAGAL karena melanggar WITH CHECK OPTION (stok = 0)
-- UPDATE v_stok_aman SET stok = 0 WHERE id_produk = 'P004';


-- ============================================================
-- SECTION 8: MANAJEMEN VIEW
-- ============================================================

-- Lihat semua view di database ini
SELECT table_name AS nama_view
FROM information_schema.views
WHERE table_schema = 'toko_online';

-- Lihat definisi / query dari sebuah view
SHOW CREATE VIEW v_total_per_pesanan;

-- Hapus view
-- DROP VIEW IF EXISTS v_produk_elektronik;
-- DROP VIEW IF EXISTS v_pelanggan_jakarta;

-- Daftar semua view yang dibuat dalam file ini:
-- v_produk_elektronik
-- v_pelanggan_jakarta
-- v_pesanan_aktif
-- v_pesanan_lengkap
-- v_detail_transaksi
-- v_total_per_pesanan
-- v_total_belanja_pelanggan
-- v_produk_terlaris
-- v_rekap_kategori
-- v_stok_aman