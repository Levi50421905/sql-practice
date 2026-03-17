-- ============================================================
--  Project   : Integrasi Data - Data Barang
--  Author    : Levi Alfarezzi (Muhammad Alfarezzi Fallevi)
--  Mata Kuliah: Insinyur Data Madya
--  Sesi      : 01 - Integrasi Data
--  Database  : MariaDB / MySQL
-- ============================================================


-- ============================================================
--  SETUP DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS sesi2;
USE sesi2;


-- ============================================================
--  TABEL BARANG
-- ============================================================

CREATE TABLE IF NOT EXISTS barang (
    id_barang  INT          PRIMARY KEY AUTO_INCREMENT,
    nm_barang  VARCHAR(100) NOT NULL,
    merk       VARCHAR(50),
    ukuran     VARCHAR(20),
    stok       INT          DEFAULT 0,
    harga      DECIMAL(10,2)
);


-- ============================================================
--  IMPORT DATA DARI CSV (LOAD DATA)
--  Pastikan file integrasiData.csv sudah ada di path yang sesuai
--  Delimiter yang digunakan: titik koma (;)
-- ============================================================

LOAD DATA LOCAL INFILE 'integrasiData.csv'
    INTO TABLE barang
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (id_barang, nm_barang, merk, ukuran, stok, harga);


-- ============================================================
--  VERIFIKASI DATA
-- ============================================================

SELECT * FROM barang;