-- ============================================================
-- File    : poliklinik.sql
-- Topik   : Studi Kasus Poliklinik - Insinyur Data Madya (Sesi 02)
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- Tanggal : Rabu, 11 Juni 2025
-- ============================================================
-- Instruksi Kerja yang dicakup:
--   IK-1 : ERD (Pasien, Dokter, Klinik, Layanan, Asuransi, Kunjungan)
--   IK-2 : CREATE TABLE semua entitas
--   IK-3 : DML (INSERT) + SELECT queries analitik
--   IK-4 : LOAD DATA INFILE dari dataKlinik.csv
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS poliklinik;
USE poliklinik;


-- ============================================================
-- SECTION 2: DDL - CREATE TABLES (Instruksi Kerja 2)
-- ============================================================
-- Urutan pembuatan: tabel induk dulu, baru tabel Kunjungan (ada FK)

-- Tabel: Pasien
CREATE TABLE IF NOT EXISTS Pasien (
    id_pasien   VARCHAR(10)  NOT NULL,
    nama_pasien VARCHAR(100),
    tgl_lahir   DATE,
    alamat      TEXT,
    no_hp       VARCHAR(15),
    PRIMARY KEY (id_pasien)
);

-- Tabel: Dokter
CREATE TABLE IF NOT EXISTS Dokter (
    id_dokter   VARCHAR(10)  NOT NULL,
    nama_dokter VARCHAR(100),
    alamat      TEXT,
    no_hp       VARCHAR(15),
    PRIMARY KEY (id_dokter)
);

-- Tabel: Klinik
CREATE TABLE IF NOT EXISTS Klinik (
    id_klinik   VARCHAR(10)  NOT NULL,
    nama_klinik VARCHAR(100),
    PRIMARY KEY (id_klinik)
);

-- Tabel: Layanan
CREATE TABLE IF NOT EXISTS Layanan (
    id_layanan   VARCHAR(10)  NOT NULL,
    jenis_layanan VARCHAR(100),
    PRIMARY KEY (id_layanan)
);

-- Tabel: Asuransi
CREATE TABLE IF NOT EXISTS Asuransi (
    id_asuransi   VARCHAR(10)  NOT NULL,
    nama_asuransi VARCHAR(100),
    PRIMARY KEY (id_asuransi)
);

-- Tabel: Kunjungan (tabel pusat, referensi semua FK)
-- Sesuai ERD: Pasien (1) --melakukan-- (M) Kunjungan (M) --ke-- Klinik/Dokter/Layanan/Asuransi
CREATE TABLE IF NOT EXISTS Kunjungan (
    id_kunjungan      VARCHAR(10) NOT NULL,
    tanggal_kunjungan DATE,
    total_bayar       INT,
    id_pasien         VARCHAR(10),
    id_dokter         VARCHAR(10),
    id_klinik         VARCHAR(10),
    id_layanan        VARCHAR(10),
    id_asuransi       VARCHAR(10),
    PRIMARY KEY (id_kunjungan),
    CONSTRAINT fk_kunj_pasien   FOREIGN KEY (id_pasien)   REFERENCES Pasien(id_pasien),
    CONSTRAINT fk_kunj_dokter   FOREIGN KEY (id_dokter)   REFERENCES Dokter(id_dokter),
    CONSTRAINT fk_kunj_klinik   FOREIGN KEY (id_klinik)   REFERENCES Klinik(id_klinik),
    CONSTRAINT fk_kunj_layanan  FOREIGN KEY (id_layanan)  REFERENCES Layanan(id_layanan),
    CONSTRAINT fk_kunj_asuransi FOREIGN KEY (id_asuransi) REFERENCES Asuransi(id_asuransi)
);


-- ============================================================
-- SECTION 3: DML - INSERT DATA (Instruksi Kerja 3)
-- ============================================================

-- Data Klinik (K01–K06 = data awal, KL010–KL012 = dari LOAD DATA CSV)
INSERT INTO Klinik (id_klinik, nama_klinik) VALUES
    ('K01', 'Poliklinik Umum'),
    ('K02', 'Klinik Penyakit Dalam'),
    ('K03', 'Klinik Mata'),
    ('K04', 'Klinik Gigi'),
    ('K05', 'Klinik THT'),
    ('K06', 'Klinik Anak'),
    ('KL010', 'Jantung'),
    ('KL011', 'Paru'),
    ('KL012', 'Saraf');

-- Data Pasien
INSERT INTO Pasien (id_pasien, nama_pasien, tgl_lahir, alamat, no_hp) VALUES
    ('P001', 'Rudianto',  '1985-03-12', 'Jl. Mawar No.1, Jakarta',   '081234567001'),
    ('P002', 'Lestari',   '1990-07-25', 'Jl. Melati No.5, Bandung',  '081234567002'),
    ('P003', 'Bambang',   '1978-11-08', 'Jl. Kenanga No.3, Surabaya','081234567003'),
    ('P004', 'Sari',      '1995-01-30', 'Jl. Dahlia No.9, Yogyakarta','081234567004'),
    ('P005', 'Hendro',    '1988-06-14', 'Jl. Anggrek No.7, Medan',   '081234567005'),
    ('P006', 'Dewi',      '2000-09-20', 'Jl. Cempaka No.11, Semarang','081234567006'),
    ('P007', 'Agus',      '1975-12-05', 'Jl. Flamboyan No.2, Malang','081234567007');

-- Data Dokter
INSERT INTO Dokter (id_dokter, nama_dokter, alamat, no_hp) VALUES
    ('D001', 'dr. Nila',   'Jl. Dokter No.1, Jakarta',   '082100000001'),
    ('D002', 'dr. Satrio', 'Jl. Dokter No.2, Jakarta',   '082100000002'),
    ('D003', 'dr. Yudi',   'Jl. Dokter No.3, Bandung',   '082100000003'),
    ('D004', 'dr. Rini',   'Jl. Dokter No.4, Surabaya',  '082100000004'),
    ('D005', 'dr. Hendra', 'Jl. Dokter No.5, Yogyakarta','082100000005');

-- Data Layanan
INSERT INTO Layanan (id_layanan, jenis_layanan) VALUES
    ('L001', 'Pemeriksaan Umum'),
    ('L002', 'Pemeriksaan Spesialis'),
    ('L003', 'Tindakan Medis'),
    ('L004', 'Rawat Inap'),
    ('L005', 'Laboratorium');

-- Data Asuransi
INSERT INTO Asuransi (id_asuransi, nama_asuransi) VALUES
    ('A001', 'ASKES'),
    ('A002', 'BPJS'),
    ('A003', 'Mandiri Inhealth'),
    ('A004', 'Allianz'),
    ('A005', 'Umum / Bayar Mandiri');

-- Data Kunjungan
INSERT INTO Kunjungan
    (id_kunjungan, tanggal_kunjungan, total_bayar, id_pasien, id_dokter, id_klinik, id_layanan, id_asuransi)
VALUES
    -- Pasien ASKES (3 kunjungan → cocok dengan hasil COUNT=3 di tugas)
    ('KJ001', '2025-06-01', 50000,  'P001', 'D001', 'K01', 'L001', 'A001'), -- Rudianto, ASKES, dr.Nila
    ('KJ002', '2025-06-02', 75000,  'P002', 'D001', 'K01', 'L002', 'A001'), -- Lestari,  ASKES, dr.Nila
    ('KJ003', '2025-06-03', 100000, 'P003', 'D002', 'K02', 'L002', 'A001'), -- Bambang,  ASKES
    -- Pasien asuransi lain
    ('KJ004', '2025-06-04', 60000,  'P004', 'D002', 'K02', 'L001', 'A002'), -- Sari,  BPJS, Klinik Penyakit Dalam, dr.Satrio
    ('KJ005', '2025-06-05', 80000,  'P005', 'D003', 'K02', 'L003', 'A003'), -- Hendro, Mandiri Inhealth, Klinik Penyakit Dalam, dr.Yudi
    ('KJ006', '2025-06-06', 120000, 'P006', 'D004', 'K03', 'L002', 'A004'), -- Dewi,  Allianz, Klinik Mata
    ('KJ007', '2025-06-07', 45000,  'P007', 'D005', 'K04', 'L001', 'A005'); -- Agus,  Bayar Mandiri


-- ============================================================
-- SECTION 4: LOAD DATA INFILE - INTEGRASI CSV (Instruksi Kerja 4)
-- ============================================================
-- Catatan: Section ini untuk referensi perintah LOAD DATA INFILE.
--          Data KL010–KL012 sudah di-INSERT manual di Section 3 agar
--          file SQL ini dapat dijalankan langsung tanpa file eksternal.
--          Gunakan perintah di bawah jika ingin load dari file CSV asli.

/*
-- Jalankan ini dari MySQL Console jika ingin load dari file CSV:

LOAD DATA LOCAL INFILE '/path/to/dataKlinik.csv'
    INTO TABLE Klinik
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (id_klinik, nama_klinik);
*/


-- ============================================================
-- SECTION 5: DQL - SELECT QUERIES (Instruksi Kerja 3)
-- ============================================================

-- 5.1 Tampilkan semua data per tabel
SELECT * FROM Pasien;
SELECT * FROM Dokter;
SELECT * FROM Klinik;
SELECT * FROM Layanan;
SELECT * FROM Asuransi;
SELECT * FROM Kunjungan;

-- ---- Instruksi Kerja 3, Soal 1 ----
-- 5.2 Hitung jumlah pasien yang menggunakan layanan ASKES
SELECT COUNT(*) AS jumlah_pasien_askes
FROM Kunjungan k
JOIN Asuransi a ON k.id_asuransi = a.id_asuransi
WHERE a.nama_asuransi = 'ASKES';
-- Hasil yang diharapkan: 3

-- ---- Instruksi Kerja 3, Soal 2 ----
-- 5.3 Tampilkan nama dokter yang berada di klinik penyakit dalam
SELECT d.nama_dokter
FROM Dokter d
JOIN Kunjungan k  ON d.id_dokter  = k.id_dokter
JOIN Klinik    kl ON k.id_klinik  = kl.id_klinik
WHERE kl.nama_klinik = 'Klinik Penyakit Dalam'
GROUP BY d.nama_dokter;
-- Hasil yang diharapkan: dr. Satrio, dr. Yudi

-- ---- Instruksi Kerja 3, Soal 3 ----
-- 5.4 Tampilkan nama pasien yang diperiksa oleh dr. Nila
SELECT p.nama_pasien
FROM Pasien p
JOIN Kunjungan k ON p.id_pasien  = k.id_pasien
JOIN Dokter    d ON k.id_dokter  = d.id_dokter
WHERE d.nama_dokter = 'dr. Nila';
-- Hasil yang diharapkan: Rudianto, Lestari


-- ============================================================
-- SECTION 6: QUERY ANALITIK TAMBAHAN
-- ============================================================

-- 6.1 Rekap kunjungan lengkap (pasien + dokter + klinik + asuransi)
SELECT
    k.id_kunjungan,
    k.tanggal_kunjungan,
    p.nama_pasien,
    d.nama_dokter,
    kl.nama_klinik,
    l.jenis_layanan,
    a.nama_asuransi,
    k.total_bayar
FROM Kunjungan k
JOIN Pasien   p  ON k.id_pasien   = p.id_pasien
JOIN Dokter   d  ON k.id_dokter   = d.id_dokter
JOIN Klinik   kl ON k.id_klinik   = kl.id_klinik
JOIN Layanan  l  ON k.id_layanan  = l.id_layanan
JOIN Asuransi a  ON k.id_asuransi = a.id_asuransi
ORDER BY k.tanggal_kunjungan;

-- 6.2 Jumlah kunjungan per klinik
SELECT
    kl.nama_klinik,
    COUNT(k.id_kunjungan) AS jumlah_kunjungan
FROM Klinik kl
LEFT JOIN Kunjungan k ON kl.id_klinik = k.id_klinik
GROUP BY kl.id_klinik, kl.nama_klinik
ORDER BY jumlah_kunjungan DESC;

-- 6.3 Total pendapatan per klinik
SELECT
    kl.nama_klinik,
    SUM(k.total_bayar) AS total_pendapatan
FROM Klinik kl
JOIN Kunjungan k ON kl.id_klinik = k.id_klinik
GROUP BY kl.id_klinik, kl.nama_klinik
ORDER BY total_pendapatan DESC;

-- 6.4 Jumlah kunjungan per jenis asuransi
SELECT
    a.nama_asuransi,
    COUNT(k.id_kunjungan) AS jumlah_kunjungan
FROM Asuransi a
LEFT JOIN Kunjungan k ON a.id_asuransi = k.id_asuransi
GROUP BY a.id_asuransi, a.nama_asuransi
ORDER BY jumlah_kunjungan DESC;

-- 6.5 Dokter dengan kunjungan terbanyak
SELECT
    d.nama_dokter,
    COUNT(k.id_kunjungan) AS jumlah_pasien_ditangani
FROM Dokter d
LEFT JOIN Kunjungan k ON d.id_dokter = k.id_dokter
GROUP BY d.id_dokter, d.nama_dokter
ORDER BY jumlah_pasien_ditangani DESC;

-- 6.6 Kunjungan per bulan (agregat bulanan)
SELECT
    DATE_FORMAT(tanggal_kunjungan, '%Y-%m') AS bulan,
    COUNT(*)                                AS jumlah_kunjungan,
    SUM(total_bayar)                        AS total_pendapatan
FROM Kunjungan
GROUP BY bulan
ORDER BY bulan;


-- ============================================================
-- SECTION 7: DESCRIBE TABLES (verifikasi struktur)
-- ============================================================

DESCRIBE Pasien;
DESCRIBE Dokter;
DESCRIBE Klinik;
DESCRIBE Layanan;
DESCRIBE Asuransi;
DESCRIBE Kunjungan;

SHOW TABLES;