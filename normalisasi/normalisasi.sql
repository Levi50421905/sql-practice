-- ============================================================
-- File    : normalisasi.sql
-- Topik   : Normalisasi Database — 1NF, 2NF, 3NF
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- Normalisasi adalah proses mendesain struktur tabel agar:
--   1. Tidak ada redundansi data
--   2. Tidak ada anomali INSERT, UPDATE, DELETE
-- Studi kasus: data pemesanan tiket seminar / workshop
-- ============================================================


-- ============================================================
-- SECTION 1: SEBELUM NORMALISASI — Tabel Tidak Ternormalisasi (0NF)
-- ============================================================
-- Masalah pada tabel di bawah:
--   - Satu kolom menyimpan banyak nilai (multi-value)
--   - Data peserta dan seminar campur dalam satu tabel
--   - Banyak kolom berulang (repeating groups)

CREATE DATABASE IF NOT EXISTS normalisasi_db;
USE normalisasi_db;

-- Tabel awal (belum dinormalisasi) — hanya untuk ilustrasi
CREATE TABLE IF NOT EXISTS pemesanan_0NF (
    id_pemesanan  VARCHAR(10),
    tgl_pesan     DATE,
    nama_peserta  VARCHAR(100),
    email         VARCHAR(100),
    telepon       VARCHAR(15),
    kota_asal     VARCHAR(50),
    nama_seminar  VARCHAR(200),  -- bisa berisi: "SQL Dasar, Python Lanjut"
    tgl_seminar   VARCHAR(200),  -- bisa berisi: "2025-06-01, 2025-06-15"
    harga         VARCHAR(200),  -- bisa berisi: "150000, 200000"
    nama_pembicara VARCHAR(200), -- bisa berisi: "Dr. Andi, Prof. Budi"
    total_bayar   INT
);

INSERT INTO pemesanan_0NF VALUES
    ('PO001', '2025-05-01', 'Levi',   'levi@email.com',   '081111', 'Jakarta',
     'SQL Dasar, Python Lanjut', '2025-06-01, 2025-06-15',
     '150000, 200000', 'Dr. Andi, Prof. Budi', 350000),
    ('PO002', '2025-05-03', 'Sari',   'sari@email.com',   '082222', 'Bandung',
     'SQL Dasar', '2025-06-01', '150000', 'Dr. Andi', 150000),
    ('PO003', '2025-05-05', 'Eko',    'eko@email.com',    '083333', 'Surabaya',
     'Python Lanjut, Data Viz', '2025-06-15, 2025-06-20',
     '200000, 175000', 'Prof. Budi, Dr. Citra', 375000);

-- Lihat masalahnya: kolom nama_seminar berisi banyak nilai!
SELECT * FROM pemesanan_0NF;


-- ============================================================
-- SECTION 2: FIRST NORMAL FORM (1NF)
-- ============================================================
-- Syarat 1NF:
--   ✅ Setiap kolom hanya berisi satu nilai (atomic)
--   ✅ Setiap baris unik (ada primary key)
--   ✅ Tidak ada repeating groups / kolom berulang
--
-- Solusi: pecah multi-value menjadi baris terpisah,
--         gunakan composite key jika perlu.

-- Tabel setelah 1NF: setiap baris = 1 peserta + 1 seminar
CREATE TABLE IF NOT EXISTS pemesanan_1NF (
    id_pemesanan   VARCHAR(10),
    tgl_pesan      DATE,
    nama_peserta   VARCHAR(100),
    email          VARCHAR(100),
    telepon        VARCHAR(15),
    kota_asal      VARCHAR(50),
    id_seminar     VARCHAR(10),
    nama_seminar   VARCHAR(100),
    tgl_seminar    DATE,
    harga_seminar  INT,
    nama_pembicara VARCHAR(100),
    PRIMARY KEY (id_pemesanan, id_seminar)  -- composite key
);

INSERT INTO pemesanan_1NF VALUES
    ('PO001','2025-05-01','Levi','levi@email.com','081111','Jakarta','S01','SQL Dasar','2025-06-01',150000,'Dr. Andi'),
    ('PO001','2025-05-01','Levi','levi@email.com','081111','Jakarta','S02','Python Lanjut','2025-06-15',200000,'Prof. Budi'),
    ('PO002','2025-05-03','Sari','sari@email.com','082222','Bandung','S01','SQL Dasar','2025-06-01',150000,'Dr. Andi'),
    ('PO003','2025-05-05','Eko','eko@email.com','083333','Surabaya','S02','Python Lanjut','2025-06-15',200000,'Prof. Budi'),
    ('PO003','2025-05-05','Eko','eko@email.com','083333','Surabaya','S03','Data Viz','2025-06-20',175000,'Dr. Citra');

SELECT * FROM pemesanan_1NF;

-- ⚠ Masalah yang masih ada di 1NF:
--   - nama_peserta, email, telepon, kota_asal BERULANG untuk PO001 dan PO003
--   - nama_seminar, harga_seminar, nama_pembicara BERULANG jika seminar yang sama dipesan banyak orang
--   → Ini adalah PARTIAL DEPENDENCY (kolom bergantung hanya pada sebagian PK)


-- ============================================================
-- SECTION 3: SECOND NORMAL FORM (2NF)
-- ============================================================
-- Syarat 2NF:
--   ✅ Sudah memenuhi 1NF
--   ✅ Tidak ada Partial Dependency:
--      semua kolom non-key harus bergantung pada SELURUH primary key
--      (relevan jika PK adalah composite key)
--
-- Identifikasi partial dependency di 1NF:
--   PK = (id_pemesanan, id_seminar)
--   - nama_peserta, email, telepon, kota_asal → hanya bergantung pada id_pemesanan ✗
--   - nama_seminar, harga_seminar, nama_pembicara → hanya bergantung pada id_seminar ✗
--   - tgl_pesan → hanya bergantung pada id_pemesanan ✗
--
-- Solusi: Pisahkan ke tabel terpisah.

-- Tabel Peserta (bergantung penuh pada id_pemesanan)
CREATE TABLE IF NOT EXISTS Peserta (
    id_peserta  VARCHAR(10) PRIMARY KEY,
    nama        VARCHAR(100),
    email       VARCHAR(100),
    telepon     VARCHAR(15),
    kota_asal   VARCHAR(50)
);

-- Tabel Seminar (bergantung penuh pada id_seminar)
CREATE TABLE IF NOT EXISTS Seminar_2NF (
    id_seminar     VARCHAR(10) PRIMARY KEY,
    nama_seminar   VARCHAR(100),
    tgl_seminar    DATE,
    harga          INT,
    nama_pembicara VARCHAR(100)
);

-- Tabel Pemesanan_2NF (junction + atribut yang bergantung pada keduanya)
CREATE TABLE IF NOT EXISTS Pemesanan_2NF (
    id_pemesanan VARCHAR(10),
    id_peserta   VARCHAR(10),
    id_seminar   VARCHAR(10),
    tgl_pesan    DATE,
    PRIMARY KEY (id_pemesanan, id_seminar),
    FOREIGN KEY (id_peserta) REFERENCES Peserta(id_peserta),
    FOREIGN KEY (id_seminar) REFERENCES Seminar_2NF(id_seminar)
);

INSERT INTO Peserta VALUES
    ('PS01', 'Levi', 'levi@email.com',  '081111', 'Jakarta'),
    ('PS02', 'Sari', 'sari@email.com',  '082222', 'Bandung'),
    ('PS03', 'Eko',  'eko@email.com',   '083333', 'Surabaya');

INSERT INTO Seminar_2NF VALUES
    ('S01', 'SQL Dasar',     '2025-06-01', 150000, 'Dr. Andi'),
    ('S02', 'Python Lanjut', '2025-06-15', 200000, 'Prof. Budi'),
    ('S03', 'Data Viz',      '2025-06-20', 175000, 'Dr. Citra');

INSERT INTO Pemesanan_2NF VALUES
    ('PO001', 'PS01', 'S01', '2025-05-01'),
    ('PO001', 'PS01', 'S02', '2025-05-01'),
    ('PO002', 'PS02', 'S01', '2025-05-03'),
    ('PO003', 'PS03', 'S02', '2025-05-05'),
    ('PO003', 'PS03', 'S03', '2025-05-05');

SELECT * FROM Peserta;
SELECT * FROM Seminar_2NF;
SELECT * FROM Pemesanan_2NF;

-- ⚠ Masalah yang masih ada di 2NF:
--   - nama_pembicara bergantung pada id_seminar ✅
--   - TAPI: pembicara punya atribut lain (bio, afiliasi, dll) yang tersimpan terpisah
--   - Lebih penting: nama_pembicara bisa berubah jika ada UPDATE → harus update semua baris
--   → Ini adalah TRANSITIVE DEPENDENCY


-- ============================================================
-- SECTION 4: THIRD NORMAL FORM (3NF)
-- ============================================================
-- Syarat 3NF:
--   ✅ Sudah memenuhi 2NF
--   ✅ Tidak ada Transitive Dependency:
--      kolom non-key tidak boleh bergantung pada kolom non-key lain
--
-- Identifikasi transitive dependency di 2NF:
--   Di tabel Seminar_2NF:
--   id_seminar → nama_pembicara → (atribut pembicara lainnya)
--   nama_pembicara bukan PK tapi menentukan data pembicara → TRANSITIVE
--
-- Solusi: pisahkan Pembicara ke tabel sendiri.

-- Tabel Pembicara
CREATE TABLE IF NOT EXISTS Pembicara (
    id_pembicara   VARCHAR(10) PRIMARY KEY,
    nama_pembicara VARCHAR(100),
    afiliasi       VARCHAR(100),
    email          VARCHAR(100)
);

-- Tabel Seminar (3NF) — nama_pembicara diganti id_pembicara (FK)
CREATE TABLE IF NOT EXISTS Seminar (
    id_seminar   VARCHAR(10) PRIMARY KEY,
    nama_seminar VARCHAR(100),
    tgl_seminar  DATE,
    harga        INT,
    id_pembicara VARCHAR(10),
    FOREIGN KEY (id_pembicara) REFERENCES Pembicara(id_pembicara)
);

-- Tabel Pemesanan (3NF) — sama dengan 2NF, relasi ke Seminar yang baru
CREATE TABLE IF NOT EXISTS Pemesanan (
    id_pemesanan VARCHAR(10),
    id_peserta   VARCHAR(10),
    id_seminar   VARCHAR(10),
    tgl_pesan    DATE,
    PRIMARY KEY (id_pemesanan, id_seminar),
    FOREIGN KEY (id_peserta) REFERENCES Peserta(id_peserta),
    FOREIGN KEY (id_seminar) REFERENCES Seminar(id_seminar)
);

INSERT INTO Pembicara VALUES
    ('PB01', 'Dr. Andi',   'Universitas Indonesia', 'andi@univ.ac.id'),
    ('PB02', 'Prof. Budi', 'ITB',                    'budi@itb.ac.id'),
    ('PB03', 'Dr. Citra',  'ITS',                    'citra@its.ac.id');

INSERT INTO Seminar VALUES
    ('S01', 'SQL Dasar',     '2025-06-01', 150000, 'PB01'),
    ('S02', 'Python Lanjut', '2025-06-15', 200000, 'PB02'),
    ('S03', 'Data Viz',      '2025-06-20', 175000, 'PB03');

INSERT INTO Pemesanan VALUES
    ('PO001', 'PS01', 'S01', '2025-05-01'),
    ('PO001', 'PS01', 'S02', '2025-05-01'),
    ('PO002', 'PS02', 'S01', '2025-05-03'),
    ('PO003', 'PS03', 'S02', '2025-05-05'),
    ('PO003', 'PS03', 'S03', '2025-05-05');


-- ============================================================
-- SECTION 5: VERIFIKASI — Query pada Struktur 3NF
-- ============================================================

-- 5.1 Rekap semua pemesanan lengkap
SELECT
    pm.id_pemesanan,
    pm.tgl_pesan,
    ps.nama           AS peserta,
    ps.kota_asal,
    s.nama_seminar,
    s.tgl_seminar,
    s.harga,
    pb.nama_pembicara
FROM Pemesanan pm
JOIN Peserta   ps ON pm.id_peserta  = ps.id_peserta
JOIN Seminar   s  ON pm.id_seminar  = s.id_seminar
JOIN Pembicara pb ON s.id_pembicara = pb.id_pembicara
ORDER BY pm.id_pemesanan, s.tgl_seminar;

-- 5.2 Total biaya per peserta
SELECT
    ps.nama,
    ps.kota_asal,
    COUNT(pm.id_seminar)  AS jumlah_seminar,
    SUM(s.harga)          AS total_bayar
FROM Pemesanan pm
JOIN Peserta ps ON pm.id_peserta = ps.id_peserta
JOIN Seminar s  ON pm.id_seminar = s.id_seminar
GROUP BY ps.id_peserta, ps.nama, ps.kota_asal
ORDER BY total_bayar DESC;

-- 5.3 Seminar mana yang paling banyak peminat?
SELECT
    s.nama_seminar,
    pb.nama_pembicara,
    COUNT(pm.id_peserta) AS jumlah_peserta,
    SUM(s.harga)         AS total_pendapatan
FROM Seminar s
JOIN Pembicara pb ON s.id_pembicara = pb.id_pembicara
LEFT JOIN Pemesanan pm ON s.id_seminar = pm.id_seminar
GROUP BY s.id_seminar, s.nama_seminar, pb.nama_pembicara
ORDER BY jumlah_peserta DESC;

-- 5.4 Peserta yang ikut lebih dari 1 seminar
SELECT
    ps.nama,
    COUNT(pm.id_seminar) AS jumlah_seminar
FROM Pemesanan pm
JOIN Peserta ps ON pm.id_peserta = ps.id_peserta
GROUP BY ps.id_peserta, ps.nama
HAVING COUNT(pm.id_seminar) > 1;