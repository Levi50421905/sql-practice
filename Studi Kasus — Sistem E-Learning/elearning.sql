-- ============================================================
-- File    : elearning.sql
-- Topik   : Studi Kasus — Sistem E-Learning
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- Sistem e-learning mencakup: mahasiswa, instruktur, kursus,
-- enrollment, progress per materi, kuis, nilai, dan sertifikat.
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP & DDL
-- ============================================================

CREATE DATABASE IF NOT EXISTS elearning_db;
USE elearning_db;

CREATE TABLE IF NOT EXISTS Instruktur (
    id_instruktur VARCHAR(10) PRIMARY KEY,
    nama          VARCHAR(100),
    email         VARCHAR(100),
    spesialisasi  VARCHAR(100),
    rating        DECIMAL(3,2) DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS Kursus (
    id_kursus    VARCHAR(10) PRIMARY KEY,
    judul        VARCHAR(200),
    deskripsi    TEXT,
    kategori     VARCHAR(50),
    level        ENUM('Pemula','Menengah','Lanjut'),
    harga        INT DEFAULT 0,
    durasi_jam   INT,
    id_instruktur VARCHAR(10),
    tgl_dibuat   DATE,
    FOREIGN KEY (id_instruktur) REFERENCES Instruktur(id_instruktur)
);

CREATE TABLE IF NOT EXISTS Materi (
    id_materi    VARCHAR(10) PRIMARY KEY,
    id_kursus    VARCHAR(10),
    judul_materi VARCHAR(200),
    urutan       INT,
    durasi_menit INT,
    FOREIGN KEY (id_kursus) REFERENCES Kursus(id_kursus)
);

CREATE TABLE IF NOT EXISTS Mahasiswa (
    id_mahasiswa VARCHAR(10) PRIMARY KEY,
    nama         VARCHAR(100),
    email        VARCHAR(100),
    kota         VARCHAR(50),
    tgl_daftar   DATE
);

CREATE TABLE IF NOT EXISTS Enrollment (
    id_enrollment VARCHAR(10) PRIMARY KEY,
    id_mahasiswa  VARCHAR(10),
    id_kursus     VARCHAR(10),
    tgl_enroll    DATE,
    tgl_selesai   DATE NULL,
    status        ENUM('Aktif','Selesai','Berhenti') DEFAULT 'Aktif',
    FOREIGN KEY (id_mahasiswa) REFERENCES Mahasiswa(id_mahasiswa),
    FOREIGN KEY (id_kursus)    REFERENCES Kursus(id_kursus)
);

CREATE TABLE IF NOT EXISTS Progress (
    id_progress  INT AUTO_INCREMENT PRIMARY KEY,
    id_enrollment VARCHAR(10),
    id_materi    VARCHAR(10),
    selesai      BOOLEAN DEFAULT FALSE,
    tgl_selesai  DATE NULL,
    FOREIGN KEY (id_enrollment) REFERENCES Enrollment(id_enrollment),
    FOREIGN KEY (id_materi)     REFERENCES Materi(id_materi)
);

CREATE TABLE IF NOT EXISTS Kuis (
    id_kuis      VARCHAR(10) PRIMARY KEY,
    id_kursus    VARCHAR(10),
    judul_kuis   VARCHAR(200),
    total_soal   INT,
    nilai_lulus  INT DEFAULT 70,
    FOREIGN KEY (id_kursus) REFERENCES Kursus(id_kursus)
);

CREATE TABLE IF NOT EXISTS Nilai_Kuis (
    id_nilai     INT AUTO_INCREMENT PRIMARY KEY,
    id_enrollment VARCHAR(10),
    id_kuis      VARCHAR(10),
    nilai        INT,
    tgl_kuis     DATE,
    lulus        BOOLEAN GENERATED ALWAYS AS (nilai >= 70) STORED,
    FOREIGN KEY (id_enrollment) REFERENCES Enrollment(id_enrollment),
    FOREIGN KEY (id_kuis)       REFERENCES Kuis(id_kuis)
);

CREATE TABLE IF NOT EXISTS Sertifikat (
    id_sertifikat VARCHAR(20) PRIMARY KEY,
    id_enrollment VARCHAR(10),
    tgl_terbit    DATE,
    FOREIGN KEY (id_enrollment) REFERENCES Enrollment(id_enrollment)
);


-- ============================================================
-- SECTION 2: INSERT DATA
-- ============================================================

INSERT INTO Instruktur VALUES
    ('I01','Dr. Andi Susanto','andi@elearn.id','Database & SQL', 4.85),
    ('I02','Budi Rahmat','budi@elearn.id','Web Development',    4.72),
    ('I03','Citra Dewi','citra@elearn.id','Data Science',       4.90),
    ('I04','Dodi Prasetya','dodi@elearn.id','Mobile Development',4.65);

INSERT INTO Kursus VALUES
    ('K01','SQL dari Nol hingga Mahir','Belajar SQL lengkap: DDL, DML, JOIN, agregasi, subquery, stored procedure','Database','Pemula',  299000, 20,'I01','2025-01-01'),
    ('K02','Web Development Full Stack','HTML, CSS, JavaScript, React, Node.js, dan deployment ke cloud',           'Web Dev', 'Menengah',499000, 40,'I02','2025-01-15'),
    ('K03','Python untuk Data Science', 'Pandas, NumPy, visualisasi data, machine learning dasar dengan scikit-learn','Data Science','Menengah',399000,30,'I03','2025-02-01'),
    ('K04','Database Lanjut & Optimasi','Normalisasi, index, query plan, replication, backup & restore',           'Database','Lanjut',   349000, 25,'I01','2025-02-15'),
    ('K05','Flutter Mobile Development','Buat aplikasi Android & iOS dengan Flutter dan Dart',                     'Mobile',  'Pemula',   449000, 35,'I04','2025-03-01');

INSERT INTO Materi VALUES
    ('M01','K01','Pengenalan Database & SQL',1,30),('M02','K01','DDL: CREATE, ALTER, DROP',2,45),
    ('M03','K01','DML: INSERT, UPDATE, DELETE',3,45),('M04','K01','SELECT & WHERE',4,60),
    ('M05','K01','JOIN Multi-Tabel',5,60),('M06','K01','Agregasi & GROUP BY',6,45),
    ('M07','K01','Subquery & CTE',7,60),('M08','K01','Stored Procedure & Trigger',8,75),
    ('M09','K02','HTML Dasar',1,60),('M10','K02','CSS & Flexbox',2,60),
    ('M11','K02','JavaScript Fundamentals',3,90),('M12','K02','React Dasar',4,90),
    ('M13','K03','Python Dasar untuk Data',1,60),('M14','K03','Pandas & DataFrames',2,90),
    ('M15','K03','Visualisasi dengan Matplotlib',3,60),('M16','K03','Machine Learning Dasar',4,90);

INSERT INTO Mahasiswa VALUES
    ('S01','Levi Alfarezzi','levi@email.com','Jakarta','2025-01-10'),
    ('S02','Sari Indah','sari@email.com','Bandung','2025-01-15'),
    ('S03','Eko Prasetyo','eko@email.com','Surabaya','2025-02-01'),
    ('S04','Dina Fitriani','dina@email.com','Yogyakarta','2025-02-10'),
    ('S05','Hendra Gunawan','hendra@email.com','Medan','2025-02-20'),
    ('S06','Putri Ayu','putri@email.com','Jakarta','2025-03-05'),
    ('S07','Rizal Maulana','rizal@email.com','Semarang','2025-03-10');

INSERT INTO Enrollment VALUES
    ('E01','S01','K01','2025-01-11','2025-03-01','Selesai'),
    ('E02','S01','K02','2025-02-01',NULL,'Aktif'),
    ('E03','S02','K01','2025-01-16','2025-03-10','Selesai'),
    ('E04','S02','K03','2025-02-05',NULL,'Aktif'),
    ('E05','S03','K02','2025-02-05',NULL,'Aktif'),
    ('E06','S04','K01','2025-02-12',NULL,'Aktif'),
    ('E07','S04','K04','2025-02-15',NULL,'Aktif'),
    ('E08','S05','K03','2025-02-22',NULL,'Aktif'),
    ('E09','S06','K01','2025-03-06',NULL,'Aktif'),
    ('E10','S07','K05','2025-03-12',NULL,'Aktif');

-- Progress materi
INSERT INTO Progress (id_enrollment, id_materi, selesai, tgl_selesai) VALUES
    ('E01','M01',TRUE,'2025-01-15'),('E01','M02',TRUE,'2025-01-20'),
    ('E01','M03',TRUE,'2025-01-25'),('E01','M04',TRUE,'2025-02-01'),
    ('E01','M05',TRUE,'2025-02-10'),('E01','M06',TRUE,'2025-02-15'),
    ('E01','M07',TRUE,'2025-02-20'),('E01','M08',TRUE,'2025-02-28'),
    ('E02','M09',TRUE,'2025-02-10'),('E02','M10',TRUE,'2025-02-20'),
    ('E02','M11',TRUE,'2025-03-01'),('E02','M12',FALSE,NULL),
    ('E03','M01',TRUE,'2025-01-20'),('E03','M02',TRUE,'2025-01-28'),
    ('E03','M03',TRUE,'2025-02-05'),('E03','M04',TRUE,'2025-02-12'),
    ('E03','M05',TRUE,'2025-02-20'),('E03','M06',TRUE,'2025-02-28'),
    ('E03','M07',TRUE,'2025-03-05'),('E03','M08',TRUE,'2025-03-09'),
    ('E06','M01',TRUE,'2025-02-15'),('E06','M02',TRUE,'2025-02-22'),
    ('E06','M03',FALSE,NULL);

INSERT INTO Kuis VALUES
    ('Q01','K01','Kuis Akhir SQL Dasar',20,70),
    ('Q02','K01','Kuis JOIN & Agregasi',15,75),
    ('Q03','K02','Kuis JavaScript',20,70),
    ('Q04','K03','Kuis Python & Pandas',20,70);

INSERT INTO Nilai_Kuis (id_enrollment, id_kuis, nilai, tgl_kuis) VALUES
    ('E01','Q01',88,'2025-02-15'),('E01','Q02',82,'2025-02-25'),
    ('E03','Q01',91,'2025-02-20'),('E03','Q02',78,'2025-03-01'),
    ('E02','Q03',75,'2025-03-05'),
    ('E04','Q04',65,'2025-03-01'),  -- tidak lulus
    ('E06','Q01',60,'2025-03-10');  -- tidak lulus

INSERT INTO Sertifikat VALUES
    ('CERT-K01-S01','E01','2025-03-02'),
    ('CERT-K01-S02','E03','2025-03-11');


-- ============================================================
-- SECTION 3: QUERY ANALITIK
-- ============================================================

-- 3.1 Daftar kursus beserta jumlah enrollment & instruktur
SELECT
    k.id_kursus, k.judul, k.level, k.harga,
    i.nama AS instruktur,
    COUNT(e.id_enrollment) AS jumlah_siswa
FROM Kursus k
JOIN Instruktur i ON k.id_instruktur = i.id_instruktur
LEFT JOIN Enrollment e ON k.id_kursus = e.id_kursus
GROUP BY k.id_kursus, k.judul, k.level, k.harga, i.nama
ORDER BY jumlah_siswa DESC;

-- 3.2 Progress belajar per mahasiswa per kursus (%)
SELECT
    m.nama AS mahasiswa,
    k.judul AS kursus,
    COUNT(p.id_progress) AS materi_ditempuh,
    SUM(p.selesai) AS materi_selesai,
    ROUND(SUM(p.selesai) / COUNT(p.id_progress) * 100, 1) AS pct_progress
FROM Enrollment e
JOIN Mahasiswa m ON e.id_mahasiswa = m.id_mahasiswa
JOIN Kursus k    ON e.id_kursus    = k.id_kursus
JOIN Progress p  ON e.id_enrollment = p.id_enrollment
GROUP BY e.id_enrollment, m.nama, k.judul
ORDER BY pct_progress DESC;

-- 3.3 Mahasiswa yang sudah selesai kursus + dapat sertifikat
SELECT
    m.nama AS mahasiswa,
    k.judul AS kursus,
    e.tgl_selesai,
    s.id_sertifikat,
    s.tgl_terbit
FROM Enrollment e
JOIN Mahasiswa m  ON e.id_mahasiswa  = m.id_mahasiswa
JOIN Kursus k     ON e.id_kursus     = k.id_kursus
LEFT JOIN Sertifikat s ON e.id_enrollment = s.id_enrollment
WHERE e.status = 'Selesai';

-- 3.4 Rekap nilai kuis per mahasiswa
SELECT
    m.nama AS mahasiswa,
    k.judul AS kursus,
    q.judul_kuis,
    nk.nilai,
    CASE WHEN nk.lulus THEN 'Lulus' ELSE 'Tidak Lulus' END AS status_kuis
FROM Nilai_Kuis nk
JOIN Enrollment e  ON nk.id_enrollment = e.id_enrollment
JOIN Mahasiswa m   ON e.id_mahasiswa   = m.id_mahasiswa
JOIN Kursus k      ON e.id_kursus      = k.id_kursus
JOIN Kuis q        ON nk.id_kuis       = q.id_kuis
ORDER BY m.nama, k.judul;

-- 3.5 Instruktur dengan total pendapatan (enrollment x harga kursus)
SELECT
    i.nama AS instruktur,
    i.spesialisasi,
    i.rating,
    COUNT(e.id_enrollment) AS total_siswa,
    SUM(k.harga) AS total_pendapatan
FROM Instruktur i
JOIN Kursus k     ON i.id_instruktur = k.id_instruktur
LEFT JOIN Enrollment e ON k.id_kursus = e.id_kursus
GROUP BY i.id_instruktur, i.nama, i.spesialisasi, i.rating
ORDER BY total_pendapatan DESC;

-- 3.6 Mahasiswa yang enroll lebih dari 1 kursus
SELECT
    m.nama,
    m.kota,
    COUNT(e.id_enrollment) AS jumlah_kursus,
    GROUP_CONCAT(k.judul SEPARATOR ' | ') AS daftar_kursus
FROM Mahasiswa m
JOIN Enrollment e ON m.id_mahasiswa = e.id_mahasiswa
JOIN Kursus k     ON e.id_kursus    = k.id_kursus
GROUP BY m.id_mahasiswa, m.nama, m.kota
HAVING COUNT(e.id_enrollment) > 1;

-- 3.7 Materi yang paling banyak belum diselesaikan
SELECT
    mt.judul_materi,
    k.judul AS kursus,
    COUNT(p.id_progress) AS total_ditempuh,
    SUM(CASE WHEN p.selesai = FALSE THEN 1 ELSE 0 END) AS belum_selesai
FROM Materi mt
JOIN Kursus k    ON mt.id_kursus  = k.id_kursus
JOIN Progress p  ON mt.id_materi  = p.id_materi
GROUP BY mt.id_materi, mt.judul_materi, k.judul
ORDER BY belum_selesai DESC;

-- 3.8 Window: ranking mahasiswa berdasarkan rata-rata nilai kuis
WITH avg_nilai AS (
    SELECT
        m.nama,
        AVG(nk.nilai) AS rata_nilai
    FROM Nilai_Kuis nk
    JOIN Enrollment e ON nk.id_enrollment = e.id_enrollment
    JOIN Mahasiswa m  ON e.id_mahasiswa   = m.id_mahasiswa
    GROUP BY m.id_mahasiswa, m.nama
)
SELECT
    nama,
    ROUND(rata_nilai, 2) AS rata_rata_nilai,
    RANK() OVER (ORDER BY rata_nilai DESC) AS peringkat
FROM avg_nilai;