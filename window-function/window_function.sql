-- ============================================================
-- File    : window_function.sql
-- Topik   : Window Function — RANK, ROW_NUMBER, LAG, LEAD, dll
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB 10.2+ / MySQL 8.0+
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- Window Function memungkinkan kalkulasi agregat TANPA
-- menghilangkan baris (berbeda dengan GROUP BY).
-- Sintaks dasar:
--   fungsi() OVER (
--     [PARTITION BY kolom]
--     [ORDER BY kolom]
--     [ROWS/RANGE frame]
--   )
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS window_func_db;
USE window_func_db;

-- Tabel: penjualan per sales per bulan
CREATE TABLE IF NOT EXISTS penjualan (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nama_sales  VARCHAR(50),
    divisi      VARCHAR(50),
    bulan       VARCHAR(7),   -- format: YYYY-MM
    total_penjualan INT
);

INSERT INTO penjualan (nama_sales, divisi, bulan, total_penjualan) VALUES
    ('Andi',    'Elektronik', '2025-01', 8200000),
    ('Budi',    'Elektronik', '2025-01', 9500000),
    ('Citra',   'Elektronik', '2025-01', 7100000),
    ('Dewi',    'Fashion',    '2025-01', 6300000),
    ('Eko',     'Fashion',    '2025-01', 8800000),
    ('Fitri',   'Fashion',    '2025-01', 7400000),
    ('Andi',    'Elektronik', '2025-02', 9100000),
    ('Budi',    'Elektronik', '2025-02', 8700000),
    ('Citra',   'Elektronik', '2025-02', 9800000),
    ('Dewi',    'Fashion',    '2025-02', 7200000),
    ('Eko',     'Fashion',    '2025-02', 6900000),
    ('Fitri',   'Fashion',    '2025-02', 8100000),
    ('Andi',    'Elektronik', '2025-03', 7600000),
    ('Budi',    'Elektronik', '2025-03', 10200000),
    ('Citra',   'Elektronik', '2025-03', 8900000),
    ('Dewi',    'Fashion',    '2025-03', 9100000),
    ('Eko',     'Fashion',    '2025-03', 7700000),
    ('Fitri',   'Fashion',    '2025-03', 8500000);

-- Tabel: nilai mahasiswa per mata kuliah
CREATE TABLE IF NOT EXISTS nilai_mahasiswa (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nama        VARCHAR(50),
    mata_kuliah VARCHAR(50),
    nilai       INT
);

INSERT INTO nilai_mahasiswa (nama, mata_kuliah, nilai) VALUES
    ('Aldi',    'Basis Data',     88),
    ('Bella',   'Basis Data',     92),
    ('Cahyo',   'Basis Data',     75),
    ('Dina',    'Basis Data',     88),
    ('Evan',    'Basis Data',     65),
    ('Aldi',    'Pemrograman Web',80),
    ('Bella',   'Pemrograman Web',95),
    ('Cahyo',   'Pemrograman Web',78),
    ('Dina',    'Pemrograman Web',82),
    ('Evan',    'Pemrograman Web',90);


-- ============================================================
-- SECTION 2: ROW_NUMBER()
-- ============================================================
-- Memberi nomor urut unik pada setiap baris dalam partisi.
-- Jika nilai sama, tetap diberi nomor berbeda (tidak ada tie).

-- 2.1 Nomor urut penjualan per divisi per bulan (diurutkan tertinggi)
SELECT
    nama_sales,
    divisi,
    bulan,
    total_penjualan,
    ROW_NUMBER() OVER (
        PARTITION BY divisi, bulan
        ORDER BY total_penjualan DESC
    ) AS urutan
FROM penjualan;

-- 2.2 Ambil hanya peringkat 1 per divisi per bulan (top sales)
SELECT *
FROM (
    SELECT
        nama_sales,
        divisi,
        bulan,
        total_penjualan,
        ROW_NUMBER() OVER (
            PARTITION BY divisi, bulan
            ORDER BY total_penjualan DESC
        ) AS urutan
    FROM penjualan
) sub
WHERE urutan = 1;


-- ============================================================
-- SECTION 3: RANK() dan DENSE_RANK()
-- ============================================================
-- RANK()       : nilai sama → ranking sama, ranking berikutnya lompat
-- DENSE_RANK() : nilai sama → ranking sama, ranking berikutnya TIDAK lompat

-- 3.1 Perbandingan RANK vs DENSE_RANK pada nilai mahasiswa
SELECT
    nama,
    mata_kuliah,
    nilai,
    RANK()       OVER (PARTITION BY mata_kuliah ORDER BY nilai DESC) AS rank_biasa,
    DENSE_RANK() OVER (PARTITION BY mata_kuliah ORDER BY nilai DESC) AS rank_dense
FROM nilai_mahasiswa;

-- 3.2 Ranking penjualan global (seluruh divisi, per bulan)
SELECT
    nama_sales,
    divisi,
    bulan,
    total_penjualan,
    RANK() OVER (
        PARTITION BY bulan
        ORDER BY total_penjualan DESC
    ) AS ranking_bulan
FROM penjualan
ORDER BY bulan, ranking_bulan;


-- ============================================================
-- SECTION 4: LAG() dan LEAD()
-- ============================================================
-- LAG(kolom, n)  : ambil nilai n baris SEBELUMNYA dalam partisi
-- LEAD(kolom, n) : ambil nilai n baris SESUDAHNYA dalam partisi
-- Berguna untuk perbandingan dengan periode sebelumnya/sesudahnya.

-- 4.1 Bandingkan penjualan bulan ini vs bulan lalu per sales
SELECT
    nama_sales,
    bulan,
    total_penjualan,
    LAG(total_penjualan, 1) OVER (
        PARTITION BY nama_sales
        ORDER BY bulan
    ) AS penjualan_bulan_lalu,
    total_penjualan - LAG(total_penjualan, 1) OVER (
        PARTITION BY nama_sales
        ORDER BY bulan
    ) AS selisih
FROM penjualan
ORDER BY nama_sales, bulan;

-- 4.2 Prediksi: tampilkan penjualan bulan depan (LEAD)
SELECT
    nama_sales,
    bulan,
    total_penjualan,
    LEAD(total_penjualan, 1) OVER (
        PARTITION BY nama_sales
        ORDER BY bulan
    ) AS penjualan_bulan_depan
FROM penjualan
ORDER BY nama_sales, bulan;

-- 4.3 Persentase pertumbuhan penjualan per sales (MoM growth)
SELECT
    nama_sales,
    bulan,
    total_penjualan,
    LAG(total_penjualan) OVER (PARTITION BY nama_sales ORDER BY bulan) AS bulan_lalu,
    ROUND(
        (total_penjualan - LAG(total_penjualan) OVER (PARTITION BY nama_sales ORDER BY bulan))
        / LAG(total_penjualan) OVER (PARTITION BY nama_sales ORDER BY bulan) * 100,
    2) AS growth_pct
FROM penjualan
ORDER BY nama_sales, bulan;


-- ============================================================
-- SECTION 5: SUM / AVG / COUNT sebagai Window Function
-- ============================================================
-- Agregat klasik bisa dipakai sebagai window function
-- dengan menambahkan OVER() → hasilnya per baris, bukan collapsed.

-- 5.1 Total penjualan divisi di setiap baris (tanpa GROUP BY)
SELECT
    nama_sales,
    divisi,
    bulan,
    total_penjualan,
    SUM(total_penjualan) OVER (PARTITION BY divisi, bulan) AS total_divisi,
    ROUND(total_penjualan /
        SUM(total_penjualan) OVER (PARTITION BY divisi, bulan) * 100, 2
    ) AS pct_kontribusi
FROM penjualan
ORDER BY bulan, divisi, total_penjualan DESC;

-- 5.2 Running total (cumulative sum) penjualan per sales
SELECT
    nama_sales,
    bulan,
    total_penjualan,
    SUM(total_penjualan) OVER (
        PARTITION BY nama_sales
        ORDER BY bulan
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS kumulatif
FROM penjualan
ORDER BY nama_sales, bulan;

-- 5.3 Moving average 2 bulan terakhir per sales
SELECT
    nama_sales,
    bulan,
    total_penjualan,
    ROUND(AVG(total_penjualan) OVER (
        PARTITION BY nama_sales
        ORDER BY bulan
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ), 0) AS avg_2_bulan
FROM penjualan
ORDER BY nama_sales, bulan;


-- ============================================================
-- SECTION 6: NTILE()
-- ============================================================
-- Membagi baris dalam partisi menjadi N kelompok (bucket) yang sama.

-- 6.1 Bagi mahasiswa menjadi 3 kelompok nilai per matkul (kuartil)
SELECT
    nama,
    mata_kuliah,
    nilai,
    NTILE(3) OVER (PARTITION BY mata_kuliah ORDER BY nilai DESC) AS kelompok
    -- 1 = nilai tertinggi, 3 = nilai terendah
FROM nilai_mahasiswa;


-- ============================================================
-- SECTION 7: FIRST_VALUE() dan LAST_VALUE()
-- ============================================================

-- 7.1 Tampilkan nilai tertinggi per matkul di setiap baris
SELECT
    nama,
    mata_kuliah,
    nilai,
    FIRST_VALUE(nama) OVER (
        PARTITION BY mata_kuliah
        ORDER BY nilai DESC
    ) AS peringkat_1,
    FIRST_VALUE(nilai) OVER (
        PARTITION BY mata_kuliah
        ORDER BY nilai DESC
    ) AS nilai_tertinggi
FROM nilai_mahasiswa;