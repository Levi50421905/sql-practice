-- ============================================================
--  Project   : Membuat dan Menguji Basis Data
--  Author    : Levi Alfarezzi (Muhammad Alfarezzi Fallevi)
--  Mata Kuliah: Insinyur Data Madya
--  Database  : MariaDB / MySQL
-- ============================================================


-- ============================================================
--  1. MEMBUAT DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS Perpustakaan;
USE Perpustakaan;


-- ============================================================
--  2. MEMBUAT TABEL
-- ============================================================

-- Tabel Buku
CREATE TABLE Buku (
    ID_Buku      INT          PRIMARY KEY AUTO_INCREMENT,
    Judul        VARCHAR(255) NOT NULL,
    Penulis      VARCHAR(255),
    Tahun_Terbit INT
);

-- Tabel Anggota
CREATE TABLE Anggota (
    ID_Anggota   INT          PRIMARY KEY AUTO_INCREMENT,
    Nama         VARCHAR(255) NOT NULL,
    Alamat       VARCHAR(255),
    Tanggal_Lahir DATE
);

-- Tabel Peminjaman (menggunakan FOREIGN KEY)
CREATE TABLE Peminjaman (
    ID_Peminjaman  INT  PRIMARY KEY AUTO_INCREMENT,
    ID_Buku        INT,
    ID_Anggota     INT,
    Tanggal_Pinjam DATE,
    Tanggal_Kembali DATE,
    FOREIGN KEY (ID_Buku)    REFERENCES Buku(ID_Buku),
    FOREIGN KEY (ID_Anggota) REFERENCES Anggota(ID_Anggota)
);


-- ============================================================
--  3. INDEX
-- ============================================================

CREATE INDEX idx_buku_penulis   ON Buku(Penulis);
CREATE INDEX idx_anggota_nama   ON Anggota(Nama);
CREATE INDEX idx_pinjam_tgl     ON Peminjaman(Tanggal_Pinjam);


-- ============================================================
--  4. MENAMBAH DATA (INSERT)
-- ============================================================

INSERT INTO Buku (Judul, Penulis, Tahun_Terbit) VALUES
    ('Belajar SQL',         'Budi',          2020),
    ('Pemrograman Python',  'Siti',          2021),
    ('Basis Data Lanjut',   'Ahmad',         2019),
    ('Clean Code',          'Robert Martin', 2008),
    ('Laskar Pelangi',      'Andrea Hirata', 2005);

INSERT INTO Anggota (Nama, Alamat, Tanggal_Lahir) VALUES
    ('Andi',  'Jl. Merdeka No.1',   '2000-05-15'),
    ('Budi',  'Jl. Sudirman No.5',  '1999-03-20'),
    ('Citra', 'Jl. Diponegoro No.8','2001-07-10'),
    ('Dewi',  'Jl. Gatot Subroto',  '2000-11-25');

INSERT INTO Peminjaman (ID_Buku, ID_Anggota, Tanggal_Pinjam, Tanggal_Kembali) VALUES
    (1, 1, '2024-01-01', '2024-01-15'),
    (2, 2, '2024-01-05', NULL),
    (3, 3, '2024-01-10', '2024-01-20'),
    (4, 1, '2024-02-01', NULL),
    (5, 4, '2024-02-15', '2024-02-25');


-- ============================================================
--  5. UPDATE DATA
-- ============================================================

-- Contoh: update nama anggota
UPDATE Anggota SET Nama = 'Andi Pratama' WHERE ID_Anggota = 1;

-- Contoh: isi tanggal kembali yang masih NULL
UPDATE Peminjaman SET Tanggal_Kembali = '2024-02-10' WHERE ID_Peminjaman = 2;


-- ============================================================
--  6. DELETE DATA
-- ============================================================

-- Hati-hati! Pastikan tidak ada foreign key yang bergantung
-- DELETE FROM Anggota WHERE ID_Anggota = 4;


-- ============================================================
--  7. KEAMANAN - GRANT AKSES
-- ============================================================

-- Memberi hak akses baca saja ke user tertentu
-- GRANT SELECT ON Perpustakaan.* TO 'user_readonly'@'localhost';

-- Memberi hak akses penuh ke admin
-- GRANT ALL PRIVILEGES ON Perpustakaan.* TO 'admin_db'@'localhost';