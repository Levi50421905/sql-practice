-- ============================================================
-- File    : subquery_cte.sql
-- Topik   : Subquery & CTE (Common Table Expression)
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB 10.2+ / MySQL 8.0+
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- Subquery  : query di dalam query lain (nested query)
-- CTE       : subquery yang diberi nama, ditulis di awal dengan WITH
--
-- Kapan pakai CTE vs Subquery?
--   Subquery  → query sederhana, dipakai 1x, kondisi WHERE/HAVING
--   CTE       → query kompleks, dipakai > 1x, perlu keterbacaan tinggi
--               recursive (pohon, hierarki)
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP — Database E-Commerce
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

CREATE TABLE IF NOT EXISTS Pelanggan (
    id_pelanggan VARCHAR(10) PRIMARY KEY,
    nama         VARCHAR(100),
    kota         VARCHAR(50),
    tgl_daftar   DATE
);

CREATE TABLE IF NOT EXISTS Produk (
    id_produk   VARCHAR(10) PRIMARY KEY,
    nama_produk VARCHAR(100),
    kategori    VARCHAR(50),
    harga       INT
);

CREATE TABLE IF NOT EXISTS Transaksi (
    id_transaksi VARCHAR(10) PRIMARY KEY,
    id_pelanggan VARCHAR(10),
    tgl_transaksi DATE,
    FOREIGN KEY (id_pelanggan) REFERENCES Pelanggan(id_pelanggan)
);

CREATE TABLE IF NOT EXISTS Detail_Transaksi (
    id_detail    INT AUTO_INCREMENT PRIMARY KEY,
    id_transaksi VARCHAR(10),
    id_produk    VARCHAR(10),
    jumlah       INT,
    harga_beli   INT,
    FOREIGN KEY (id_transaksi) REFERENCES Transaksi(id_transaksi),
    FOREIGN KEY (id_produk)    REFERENCES Produk(id_produk)
);

INSERT INTO Pelanggan VALUES
    ('C001', 'Andi',   'Jakarta',   '2024-01-10'),
    ('C002', 'Bella',  'Bandung',   '2024-02-15'),
    ('C003', 'Cahyo',  'Surabaya',  '2024-03-01'),
    ('C004', 'Dina',   'Jakarta',   '2024-04-20'),
    ('C005', 'Evan',   'Medan',     '2024-05-05'),
    ('C006', 'Fitri',  'Yogyakarta','2024-06-18'),
    ('C007', 'Galih',  'Bandung',   '2024-07-22');

INSERT INTO Produk VALUES
    ('P001', 'Laptop Ultra',    'Elektronik', 14000000),
    ('P002', 'Smartphone X',    'Elektronik',  8500000),
    ('P003', 'Headphone Pro',   'Elektronik',   950000),
    ('P004', 'Meja Minimalis',  'Furniture',   2100000),
    ('P005', 'Kursi Gaming',    'Furniture',   3200000),
    ('P006', 'Buku Python',     'Buku',          89000),
    ('P007', 'Buku SQL Expert', 'Buku',         125000),
    ('P008', 'Kamera Mirrorless','Elektronik', 18500000);

INSERT INTO Transaksi VALUES
    ('T001', 'C001', '2025-01-05'),
    ('T002', 'C002', '2025-01-12'),
    ('T003', 'C001', '2025-02-03'),
    ('T004', 'C003', '2025-02-18'),
    ('T005', 'C004', '2025-02-25'),
    ('T006', 'C005', '2025-03-10'),
    ('T007', 'C002', '2025-03-15'),
    ('T008', 'C006', '2025-03-20'),
    ('T009', 'C001', '2025-04-01'),
    ('T010', 'C007', '2025-04-08');

INSERT INTO Detail_Transaksi (id_transaksi, id_produk, jumlah, harga_beli) VALUES
    ('T001', 'P001', 1, 14000000),
    ('T001', 'P003', 2,   950000),
    ('T002', 'P002', 1,  8500000),
    ('T002', 'P006', 3,    89000),
    ('T003', 'P004', 1,  2100000),
    ('T003', 'P007', 2,   125000),
    ('T004', 'P005', 1,  3200000),
    ('T004', 'P003', 1,   950000),
    ('T005', 'P001', 1, 14000000),
    ('T005', 'P002', 1,  8500000),
    ('T006', 'P008', 1, 18500000),
    ('T007', 'P004', 1,  2100000),
    ('T007', 'P005', 1,  3200000),
    ('T008', 'P006', 5,    89000),
    ('T008', 'P007', 3,   125000),
    ('T009', 'P003', 1,   950000),
    ('T010', 'P002', 1,  8500000);


-- ============================================================
-- SECTION 2: SUBQUERY DI WHERE
-- ============================================================

-- 2.1 Produk yang harganya di atas rata-rata semua produk
SELECT id_produk, nama_produk, harga
FROM Produk
WHERE harga > (SELECT AVG(harga) FROM Produk)
ORDER BY harga DESC;

-- 2.2 Pelanggan yang pernah membeli produk Elektronik
SELECT DISTINCT pl.nama, pl.kota
FROM Pelanggan pl
WHERE pl.id_pelanggan IN (
    SELECT t.id_pelanggan
    FROM Transaksi t
    JOIN Detail_Transaksi dt ON t.id_transaksi = dt.id_transaksi
    JOIN Produk pr            ON dt.id_produk   = pr.id_produk
    WHERE pr.kategori = 'Elektronik'
);

-- 2.3 Pelanggan yang BELUM pernah bertransaksi (NOT IN)
SELECT id_pelanggan, nama, kota
FROM Pelanggan
WHERE id_pelanggan NOT IN (
    SELECT DISTINCT id_pelanggan FROM Transaksi
);

-- 2.4 Produk yang pernah dibeli minimal 2 kali (EXISTS)
SELECT id_produk, nama_produk
FROM Produk pr
WHERE EXISTS (
    SELECT 1
    FROM Detail_Transaksi dt
    WHERE dt.id_produk = pr.id_produk
    GROUP BY dt.id_produk
    HAVING SUM(dt.jumlah) >= 2
);


-- ============================================================
-- SECTION 3: SUBQUERY DI FROM (DERIVED TABLE)
-- ============================================================

-- 3.1 Rata-rata total transaksi per pelanggan
SELECT AVG(total_per_pelanggan) AS rata_rata_transaksi
FROM (
    SELECT
        id_pelanggan,
        COUNT(id_transaksi) AS total_per_pelanggan
    FROM Transaksi
    GROUP BY id_pelanggan
) AS sub;

-- 3.2 Pelanggan dengan total belanja di atas rata-rata semua pelanggan
SELECT nama_pelanggan, total_belanja
FROM (
    SELECT
        pl.nama AS nama_pelanggan,
        SUM(dt.jumlah * dt.harga_beli) AS total_belanja
    FROM Pelanggan pl
    JOIN Transaksi t        ON pl.id_pelanggan = t.id_pelanggan
    JOIN Detail_Transaksi dt ON t.id_transaksi  = dt.id_transaksi
    GROUP BY pl.id_pelanggan, pl.nama
) AS sub_belanja
WHERE total_belanja > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(dt2.jumlah * dt2.harga_beli) AS total
        FROM Transaksi t2
        JOIN Detail_Transaksi dt2 ON t2.id_transaksi = dt2.id_transaksi
        GROUP BY t2.id_pelanggan
    ) AS avg_sub
)
ORDER BY total_belanja DESC;

-- 3.3 Top 3 produk terlaris per kategori
SELECT *
FROM (
    SELECT
        pr.kategori,
        pr.nama_produk,
        SUM(dt.jumlah)                   AS total_unit,
        SUM(dt.jumlah * dt.harga_beli)   AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY pr.kategori
            ORDER BY SUM(dt.jumlah) DESC
        ) AS rn
    FROM Produk pr
    JOIN Detail_Transaksi dt ON pr.id_produk = dt.id_produk
    GROUP BY pr.id_produk, pr.kategori, pr.nama_produk
) AS ranked
WHERE rn <= 3;


-- ============================================================
-- SECTION 4: SUBQUERY DI SELECT (SCALAR SUBQUERY)
-- ============================================================

-- 4.1 Tampilkan setiap transaksi beserta total item-nya
SELECT
    t.id_transaksi,
    t.id_pelanggan,
    t.tgl_transaksi,
    (SELECT SUM(dt.jumlah * dt.harga_beli)
     FROM Detail_Transaksi dt
     WHERE dt.id_transaksi = t.id_transaksi) AS total_bayar
FROM Transaksi t
ORDER BY total_bayar DESC;

-- 4.2 Tampilkan setiap produk + jumlah berapa kali pernah dibeli
SELECT
    pr.id_produk,
    pr.nama_produk,
    pr.harga,
    (SELECT COUNT(*) FROM Detail_Transaksi dt WHERE dt.id_produk = pr.id_produk) AS frekuensi_beli
FROM Produk pr
ORDER BY frekuensi_beli DESC;


-- ============================================================
-- SECTION 5: CTE — WITH (non-recursive)
-- ============================================================
-- CTE lebih mudah dibaca karena query diberi nama dan ditulis di atas.

-- 5.1 CTE sederhana: total belanja per pelanggan
WITH total_belanja AS (
    SELECT
        pl.id_pelanggan,
        pl.nama,
        pl.kota,
        SUM(dt.jumlah * dt.harga_beli) AS total
    FROM Pelanggan pl
    JOIN Transaksi t         ON pl.id_pelanggan = t.id_pelanggan
    JOIN Detail_Transaksi dt ON t.id_transaksi  = dt.id_transaksi
    GROUP BY pl.id_pelanggan, pl.nama, pl.kota
)
SELECT * FROM total_belanja ORDER BY total DESC;

-- 5.2 CTE berantai (multiple CTE): identifikasi pelanggan VIP
WITH total_belanja AS (
    SELECT
        pl.id_pelanggan,
        pl.nama,
        pl.kota,
        SUM(dt.jumlah * dt.harga_beli) AS total
    FROM Pelanggan pl
    JOIN Transaksi t         ON pl.id_pelanggan = t.id_pelanggan
    JOIN Detail_Transaksi dt ON t.id_transaksi  = dt.id_transaksi
    GROUP BY pl.id_pelanggan, pl.nama, pl.kota
),
rata_rata AS (
    SELECT AVG(total) AS avg_belanja FROM total_belanja
),
pelanggan_vip AS (
    SELECT tb.*, 'VIP' AS status
    FROM total_belanja tb, rata_rata
    WHERE tb.total > rata_rata.avg_belanja
)
SELECT * FROM pelanggan_vip ORDER BY total DESC;

-- 5.3 CTE untuk menghindari duplikasi subquery
WITH revenue_produk AS (
    SELECT
        pr.id_produk,
        pr.nama_produk,
        pr.kategori,
        SUM(dt.jumlah * dt.harga_beli) AS revenue
    FROM Produk pr
    JOIN Detail_Transaksi dt ON pr.id_produk = dt.id_produk
    GROUP BY pr.id_produk, pr.nama_produk, pr.kategori
)
-- Pakai CTE dua kali dalam satu query
SELECT
    rp.*,
    ROUND(rp.revenue / SUM(rp.revenue) OVER (PARTITION BY rp.kategori) * 100, 2) AS pct_dalam_kategori
FROM revenue_produk rp
ORDER BY rp.kategori, rp.revenue DESC;


-- ============================================================
-- SECTION 6: RECURSIVE CTE
-- ============================================================
-- Recursive CTE berguna untuk data hierarki / pohon.
-- Contoh: struktur organisasi (karyawan → manager → direktur)

CREATE TABLE IF NOT EXISTS Karyawan (
    id_karyawan  INT PRIMARY KEY,
    nama         VARCHAR(100),
    jabatan      VARCHAR(50),
    id_manager   INT NULL,  -- NULL = pimpinan tertinggi
    FOREIGN KEY (id_manager) REFERENCES Karyawan(id_karyawan)
);

INSERT INTO Karyawan VALUES
    (1,  'Budi',    'Direktur',        NULL),
    (2,  'Andi',    'Manajer IT',      1),
    (3,  'Sari',    'Manajer HR',      1),
    (4,  'Citra',   'Senior Dev',      2),
    (5,  'Dodi',    'Junior Dev',      4),
    (6,  'Eko',     'Junior Dev',      4),
    (7,  'Fitri',   'HR Specialist',   3),
    (8,  'Galih',   'Senior Dev',      2),
    (9,  'Hana',    'Junior Dev',      8);

-- 6.1 Tampilkan seluruh struktur organisasi dari atas ke bawah
WITH RECURSIVE org_chart AS (
    -- Anchor: mulai dari pimpinan tertinggi (tanpa manager)
    SELECT
        id_karyawan,
        nama,
        jabatan,
        id_manager,
        0           AS level,
        CAST(nama AS CHAR(500)) AS path
    FROM Karyawan
    WHERE id_manager IS NULL

    UNION ALL

    -- Recursive: sambungkan ke bawahan
    SELECT
        k.id_karyawan,
        k.nama,
        k.jabatan,
        k.id_manager,
        oc.level + 1,
        CONCAT(oc.path, ' > ', k.nama)
    FROM Karyawan k
    JOIN org_chart oc ON k.id_manager = oc.id_karyawan
)
SELECT
    CONCAT(REPEAT('  ', level), nama) AS struktur,
    jabatan,
    level,
    path
FROM org_chart
ORDER BY path;

-- 6.2 Hitung berapa banyak bawahan langsung tiap manager
WITH RECURSIVE bawahan AS (
    SELECT id_karyawan, id_manager FROM Karyawan
    UNION ALL
    SELECT k.id_karyawan, b.id_manager
    FROM Karyawan k
    JOIN bawahan b ON k.id_manager = b.id_karyawan
)
SELECT
    m.nama AS manager,
    m.jabatan,
    COUNT(b.id_karyawan) - 1 AS jumlah_bawahan  -- kurangi dirinya sendiri
FROM bawahan b
JOIN Karyawan m ON b.id_manager = m.id_karyawan
GROUP BY m.id_karyawan, m.nama, m.jabatan
ORDER BY jumlah_bawahan DESC;