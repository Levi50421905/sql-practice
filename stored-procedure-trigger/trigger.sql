-- ============================================================
--  Project   : Trigger - Studi Kasus Penjualan Makanan
--  Author    : Levi Alfarezzi (Muhammad Alfarezzi Fallevi)
--  Mata Kuliah: Insinyur Data Madya
--  Database  : MySQL / MariaDB
-- ============================================================


-- ============================================================
--  1. BUAT DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS PenjualanMakanan;
USE PenjualanMakanan;


-- ============================================================
--  2. BUAT TABEL PENJUALAN
-- ============================================================

CREATE TABLE IF NOT EXISTS Penjualan (
    id              INT           PRIMARY KEY AUTO_INCREMENT,
    nama_makanan    VARCHAR(100)  NOT NULL,
    jumlah          INT           NOT NULL CHECK (jumlah > 0),
    harga_per_unit  DECIMAL(10,2) NOT NULL,
    total_harga     DECIMAL(10,2) NOT NULL,
    tanggal         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
--  3. BUAT TABEL LOG
-- ============================================================

CREATE TABLE IF NOT EXISTS LogPenjualan (
    id          INT          PRIMARY KEY AUTO_INCREMENT,
    aksi        VARCHAR(10)  NOT NULL,   -- INSERT / UPDATE / DELETE
    id_penjualan INT,
    nama_makanan VARCHAR(100),
    jumlah      INT,
    total_harga DECIMAL(10,2),
    waktu       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    pengguna    VARCHAR(100) DEFAULT USER()
);


-- ============================================================
--  4.1 TRIGGER UNTUK INSERT
--  Mencatat setiap penjualan baru
-- ============================================================

DELIMITER //

CREATE TRIGGER trg_penjualan_insert
AFTER INSERT ON Penjualan
FOR EACH ROW
BEGIN
    INSERT INTO LogPenjualan (aksi, id_penjualan, nama_makanan, jumlah, total_harga)
    VALUES ('INSERT', NEW.id, NEW.nama_makanan, NEW.jumlah, NEW.total_harga);
END //

DELIMITER ;


-- ============================================================
--  4.2 TRIGGER UNTUK UPDATE
--  Mencatat setiap perubahan data penjualan
-- ============================================================

DELIMITER //

CREATE TRIGGER trg_penjualan_update
AFTER UPDATE ON Penjualan
FOR EACH ROW
BEGIN
    INSERT INTO LogPenjualan (aksi, id_penjualan, nama_makanan, jumlah, total_harga)
    VALUES ('UPDATE', NEW.id, NEW.nama_makanan, NEW.jumlah, NEW.total_harga);
END //

DELIMITER ;


-- ============================================================
--  4.3 TRIGGER UNTUK DELETE
--  Mencatat setiap penghapusan data penjualan
-- ============================================================

DELIMITER //

CREATE TRIGGER trg_penjualan_delete
BEFORE DELETE ON Penjualan
FOR EACH ROW
BEGIN
    INSERT INTO LogPenjualan (aksi, id_penjualan, nama_makanan, jumlah, total_harga)
    VALUES ('DELETE', OLD.id, OLD.nama_makanan, OLD.jumlah, OLD.total_harga);
END //

DELIMITER ;


-- ============================================================
--  5. PENGUJIAN TRIGGER
-- ============================================================

-- Test INSERT
INSERT INTO Penjualan (nama_makanan, jumlah, harga_per_unit, total_harga)
VALUES ('Nasi Goreng',  2, 20000, 40000);

INSERT INTO Penjualan (nama_makanan, jumlah, harga_per_unit, total_harga)
VALUES ('Mie Ayam',     3, 15000, 45000);

INSERT INTO Penjualan (nama_makanan, jumlah, harga_per_unit, total_harga)
VALUES ('Ayam Bakar',   1, 35000, 35000);

-- Test UPDATE
UPDATE Penjualan
SET jumlah = 3, total_harga = 60000
WHERE id = 1;

-- Test DELETE
DELETE FROM Penjualan
WHERE id = 2;

-- Cek tabel Penjualan
SELECT * FROM Penjualan;

-- Cek LogPenjualan untuk memastikan trigger bekerja
SELECT * FROM LogPenjualan ORDER BY waktu;


-- ============================================================
--  BONUS: TRIGGER PERPUSTAKAAN
--  Otomatis kurangi/tambah stok buku saat dipinjam/dikembalikan
-- ============================================================

USE Perpustakaan;

-- Trigger: kurangi stok saat buku dipinjam (INSERT ke Peminjaman)
DELIMITER //

CREATE TRIGGER after_borrow_insert
AFTER INSERT ON Peminjaman
FOR EACH ROW
BEGIN
    UPDATE Buku
    SET stock = stock - 1
    WHERE ID_Buku = NEW.ID_Buku;
END //

DELIMITER ;

-- Trigger: tambah stok saat buku dikembalikan (UPDATE Peminjaman)
DELIMITER //

CREATE TRIGGER after_borrow_update
AFTER UPDATE ON Peminjaman
FOR EACH ROW
BEGIN
    IF NEW.Tanggal_Kembali IS NOT NULL AND OLD.Tanggal_Kembali IS NULL THEN
        UPDATE Buku
        SET stock = stock + 1
        WHERE ID_Buku = NEW.ID_Buku;
    END IF;
END //

DELIMITER ;

-- Cek trigger yang terdaftar
SHOW TRIGGERS FROM PenjualanMakanan;
SHOW TRIGGERS FROM Perpustakaan;