-- ============================================================
-- File    : inventori.sql
-- Topik   : Studi Kasus — Sistem Inventori & Gudang
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP & DDL
-- ============================================================

CREATE DATABASE IF NOT EXISTS inventori_db;
USE inventori_db;

CREATE TABLE IF NOT EXISTS Supplier (
    id_supplier  VARCHAR(10) PRIMARY KEY,
    nama         VARCHAR(100),
    kontak       VARCHAR(100),
    kota         VARCHAR(50),
    email        VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Kategori (
    id_kategori  VARCHAR(10) PRIMARY KEY,
    nama_kategori VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Produk (
    id_produk    VARCHAR(10) PRIMARY KEY,
    nama_produk  VARCHAR(200),
    id_kategori  VARCHAR(10),
    id_supplier  VARCHAR(10),
    satuan       VARCHAR(20),
    harga_beli   INT,
    harga_jual   INT,
    stok_minimum INT DEFAULT 5,
    FOREIGN KEY (id_kategori) REFERENCES Kategori(id_kategori),
    FOREIGN KEY (id_supplier) REFERENCES Supplier(id_supplier)
);

CREATE TABLE IF NOT EXISTS Gudang (
    id_gudang   VARCHAR(10) PRIMARY KEY,
    nama_gudang VARCHAR(100),
    lokasi      VARCHAR(100),
    kapasitas   INT
);

CREATE TABLE IF NOT EXISTS Stok (
    id_stok    INT AUTO_INCREMENT PRIMARY KEY,
    id_produk  VARCHAR(10),
    id_gudang  VARCHAR(10),
    jumlah     INT DEFAULT 0,
    UNIQUE KEY uk_produk_gudang (id_produk, id_gudang),
    FOREIGN KEY (id_produk) REFERENCES Produk(id_produk),
    FOREIGN KEY (id_gudang) REFERENCES Gudang(id_gudang)
);

CREATE TABLE IF NOT EXISTS Mutasi_Stok (
    id_mutasi   INT AUTO_INCREMENT PRIMARY KEY,
    id_produk   VARCHAR(10),
    id_gudang   VARCHAR(10),
    jenis       ENUM('MASUK','KELUAR','TRANSFER'),
    jumlah      INT,
    keterangan  VARCHAR(255),
    tgl_mutasi  DATE,
    dibuat_pada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produk) REFERENCES Produk(id_produk),
    FOREIGN KEY (id_gudang) REFERENCES Gudang(id_gudang)
);

CREATE TABLE IF NOT EXISTS Purchase_Order (
    id_po       VARCHAR(10) PRIMARY KEY,
    id_supplier VARCHAR(10),
    tgl_po      DATE,
    tgl_terima  DATE NULL,
    status      ENUM('Draft','Dikirim','Diterima','Dibatalkan') DEFAULT 'Draft',
    FOREIGN KEY (id_supplier) REFERENCES Supplier(id_supplier)
);

CREATE TABLE IF NOT EXISTS Detail_PO (
    id_detail   INT AUTO_INCREMENT PRIMARY KEY,
    id_po       VARCHAR(10),
    id_produk   VARCHAR(10),
    jumlah_pesan INT,
    harga_satuan INT,
    FOREIGN KEY (id_po)      REFERENCES Purchase_Order(id_po),
    FOREIGN KEY (id_produk)  REFERENCES Produk(id_produk)
);


-- ============================================================
-- SECTION 2: INSERT DATA
-- ============================================================

INSERT INTO Supplier VALUES
    ('SUP01','PT Elektronik Jaya','Budi / 08111','Jakarta','budi@elektronikjaya.com'),
    ('SUP02','CV Alat Tulis Maju','Andi / 08222','Bandung','andi@atkmaju.com'),
    ('SUP03','UD Furniture Prima','Sari / 08333','Semarang','sari@furniprima.com');

INSERT INTO Kategori VALUES
    ('KAT01','Elektronik'),('KAT02','Alat Tulis'),
    ('KAT03','Furniture'),('KAT04','Aksesoris Komputer');

INSERT INTO Produk VALUES
    ('PRD01','Laptop Standar',    'KAT01','SUP01','Unit', 8000000,10000000,3),
    ('PRD02','Mouse Wireless',    'KAT04','SUP01','Unit',  100000,  185000,10),
    ('PRD03','Keyboard USB',      'KAT04','SUP01','Unit',   75000,  120000,10),
    ('PRD04','Pulpen Pilot',      'KAT02','SUP02','Lusin',  20000,   35000,20),
    ('PRD05','Buku Tulis A4',     'KAT02','SUP02','Rim',    40000,   65000,15),
    ('PRD06','Kursi Kantor',      'KAT03','SUP03','Unit',  800000, 1200000, 5),
    ('PRD07','Meja Kerja',        'KAT03','SUP03','Unit', 1200000, 1800000, 3),
    ('PRD08','Monitor 24"',       'KAT01','SUP01','Unit', 1800000, 2500000, 5);

INSERT INTO Gudang VALUES
    ('GDG01','Gudang Utama Jakarta',  'Jakarta Utara',  5000),
    ('GDG02','Gudang Cabang Bandung', 'Bandung Barat',  2000),
    ('GDG03','Gudang Cabang Surabaya','Surabaya Timur', 3000);

INSERT INTO Stok (id_produk, id_gudang, jumlah) VALUES
    ('PRD01','GDG01',15),('PRD01','GDG02', 5),('PRD01','GDG03', 8),
    ('PRD02','GDG01',50),('PRD02','GDG02',20),
    ('PRD03','GDG01',45),('PRD03','GDG03',15),
    ('PRD04','GDG01',30),('PRD04','GDG02',25),
    ('PRD05','GDG01',20),('PRD05','GDG02', 3),  -- stok hampir habis
    ('PRD06','GDG01', 8),('PRD06','GDG03', 4),
    ('PRD07','GDG01', 6),
    ('PRD08','GDG01',12),('PRD08','GDG02', 2);  -- GDG02 hampir habis

INSERT INTO Mutasi_Stok (id_produk, id_gudang, jenis, jumlah, keterangan, tgl_mutasi) VALUES
    ('PRD01','GDG01','MASUK', 5,'Penerimaan PO-001','2025-05-01'),
    ('PRD02','GDG01','KELUAR',10,'Penjualan ke PT ABC','2025-05-02'),
    ('PRD03','GDG01','MASUK',20,'Penerimaan PO-002','2025-05-03'),
    ('PRD01','GDG02','TRANSFER',3,'Transfer dari GDG01','2025-05-05'),
    ('PRD04','GDG01','KELUAR',15,'Penjualan ke CV XYZ','2025-05-06'),
    ('PRD05','GDG02','KELUAR',10,'Penjualan retail','2025-05-08'),
    ('PRD08','GDG01','MASUK',10,'Penerimaan PO-003','2025-05-10'),
    ('PRD06','GDG01','KELUAR', 2,'Penjualan ke kantor','2025-05-12');

INSERT INTO Purchase_Order VALUES
    ('PO001','SUP01','2025-04-28','2025-05-01','Diterima'),
    ('PO002','SUP01','2025-04-30','2025-05-03','Diterima'),
    ('PO003','SUP01','2025-05-08','2025-05-10','Diterima'),
    ('PO004','SUP02','2025-05-15',NULL,'Dikirim');

INSERT INTO Detail_PO VALUES
    (DEFAULT,'PO001','PRD01',5,8000000),
    (DEFAULT,'PO002','PRD03',20,75000),
    (DEFAULT,'PO003','PRD08',10,1800000),
    (DEFAULT,'PO004','PRD04',30,20000),
    (DEFAULT,'PO004','PRD05',15,40000);


-- ============================================================
-- SECTION 3: QUERY ANALITIK
-- ============================================================

-- 3.1 Stok total per produk (semua gudang)
SELECT
    p.id_produk, p.nama_produk, k.nama_kategori,
    SUM(s.jumlah)      AS total_stok,
    p.stok_minimum,
    CASE WHEN SUM(s.jumlah) <= p.stok_minimum THEN '⚠ Stok Menipis' ELSE 'Aman' END AS status_stok
FROM Produk p
JOIN Kategori k ON p.id_kategori = k.id_kategori
LEFT JOIN Stok s ON p.id_produk = s.id_produk
GROUP BY p.id_produk, p.nama_produk, k.nama_kategori, p.stok_minimum
ORDER BY total_stok;

-- 3.2 Stok per gudang (pivot view)
SELECT
    p.nama_produk,
    SUM(CASE WHEN s.id_gudang = 'GDG01' THEN s.jumlah ELSE 0 END) AS GDG01_Jakarta,
    SUM(CASE WHEN s.id_gudang = 'GDG02' THEN s.jumlah ELSE 0 END) AS GDG02_Bandung,
    SUM(CASE WHEN s.id_gudang = 'GDG03' THEN s.jumlah ELSE 0 END) AS GDG03_Surabaya,
    SUM(s.jumlah) AS total
FROM Produk p
JOIN Stok s ON p.id_produk = s.id_produk
GROUP BY p.id_produk, p.nama_produk
ORDER BY total DESC;

-- 3.3 Riwayat mutasi stok per produk
SELECT
    ms.tgl_mutasi, p.nama_produk, g.nama_gudang,
    ms.jenis, ms.jumlah, ms.keterangan
FROM Mutasi_Stok ms
JOIN Produk p ON ms.id_produk = ms.id_produk
JOIN Gudang g ON ms.id_gudang = g.id_gudang
ORDER BY ms.tgl_mutasi DESC, ms.dibuat_pada DESC;

-- 3.4 Nilai inventori per gudang (stok × harga beli)
SELECT
    g.nama_gudang,
    COUNT(DISTINCT s.id_produk)        AS jumlah_jenis_produk,
    SUM(s.jumlah)                      AS total_unit,
    SUM(s.jumlah * p.harga_beli)       AS nilai_inventori,
    SUM(s.jumlah * p.harga_jual)       AS potensi_revenue
FROM Gudang g
JOIN Stok s   ON g.id_gudang  = s.id_gudang
JOIN Produk p ON s.id_produk  = p.id_produk
GROUP BY g.id_gudang, g.nama_gudang
ORDER BY nilai_inventori DESC;

-- 3.5 Purchase Order beserta total nilai PO
SELECT
    po.id_po, sp.nama AS supplier,
    po.tgl_po, po.tgl_terima, po.status,
    SUM(dp.jumlah_pesan * dp.harga_satuan) AS total_nilai_po
FROM Purchase_Order po
JOIN Supplier sp    ON po.id_supplier = sp.id_supplier
JOIN Detail_PO dp   ON po.id_po       = dp.id_po
GROUP BY po.id_po, sp.nama, po.tgl_po, po.tgl_terima, po.status
ORDER BY po.tgl_po DESC;

-- 3.6 Produk yang perlu di-restock (stok total ≤ stok minimum)
SELECT
    p.nama_produk, sp.nama AS supplier, sp.email,
    p.stok_minimum, SUM(s.jumlah) AS stok_saat_ini,
    (p.stok_minimum - SUM(s.jumlah)) AS kekurangan
FROM Produk p
JOIN Supplier sp ON p.id_supplier = sp.id_supplier
LEFT JOIN Stok s ON p.id_produk   = s.id_produk
GROUP BY p.id_produk, p.nama_produk, sp.nama, sp.email, p.stok_minimum
HAVING SUM(s.jumlah) <= p.stok_minimum
ORDER BY kekurangan DESC;

-- 3.7 Running total mutasi MASUK per produk (CTE + Window)
WITH mutasi_masuk AS (
    SELECT
        p.nama_produk,
        ms.tgl_mutasi,
        ms.jumlah
    FROM Mutasi_Stok ms
    JOIN Produk p ON ms.id_produk = p.id_produk
    WHERE ms.jenis = 'MASUK'
)
SELECT
    nama_produk, tgl_mutasi, jumlah,
    SUM(jumlah) OVER (PARTITION BY nama_produk ORDER BY tgl_mutasi
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS kumulatif_masuk
FROM mutasi_masuk
ORDER BY nama_produk, tgl_mutasi;