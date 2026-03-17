-- ============================================================
--  Project   : Menguji Basis Data - Query Testing
--  Author    : Levi Alfarezzi (Muhammad Alfarezzi Fallevi)
--  Mata Kuliah: Insinyur Data Madya
--  Database  : MariaDB / MySQL
-- ============================================================

USE Perpustakaan;


-- ============================================================
--  BAGIAN 1 - VALIDASI SKEMA
--  Memastikan tabel dan kolom sudah dibuat dengan benar
-- ============================================================

-- Lihat semua tabel di database
SHOW TABLES;

-- Lihat struktur tabel
DESCRIBE Buku;
DESCRIBE Anggota;
DESCRIBE Peminjaman;

-- Cek foreign key yang terdaftar
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Perpustakaan'
  AND REFERENCED_TABLE_NAME IS NOT NULL;


-- ============================================================
--  BAGIAN 2 - PENGUJIAN DATA
--  Memastikan data tersimpan dengan benar
-- ============================================================

-- Lihat semua data
SELECT * FROM Buku;
SELECT * FROM Anggota;
SELECT * FROM Peminjaman;

-- Cari buku berdasarkan tahun terbit
SELECT * FROM Buku WHERE Tahun_Terbit > 2010;

-- Cari peminjaman yang belum dikembalikan
SELECT * FROM Peminjaman WHERE Tanggal_Kembali IS NULL;

-- Cari peminjaman setelah tanggal tertentu
SELECT * FROM Peminjaman WHERE Tanggal_Pinjam > '2024-01-01';

-- Cek data integrity: pastikan tidak ada ID_Buku yang tidak valid
SELECT p.*
FROM Peminjaman p
LEFT JOIN Buku b ON p.ID_Buku = b.ID_Buku
WHERE b.ID_Buku IS NULL;


-- ============================================================
--  BAGIAN 3 - PENGUJIAN JOIN
--  Memastikan relasi antar tabel bekerja dengan benar
-- ============================================================

-- Siapa meminjam buku apa?
SELECT
    a.Nama           AS Anggota,
    b.Judul          AS Buku,
    b.Penulis,
    p.Tanggal_Pinjam,
    p.Tanggal_Kembali,
    CASE
        WHEN p.Tanggal_Kembali IS NULL THEN 'Belum Dikembalikan'
        ELSE 'Sudah Dikembalikan'
    END AS Status
FROM Peminjaman p
INNER JOIN Anggota a ON p.ID_Anggota = a.ID_Anggota
INNER JOIN Buku    b ON p.ID_Buku    = b.ID_Buku
ORDER BY p.Tanggal_Pinjam DESC;

-- Anggota yang belum pernah meminjam (LEFT JOIN)
SELECT a.Nama, a.Alamat
FROM Anggota a
LEFT JOIN Peminjaman p ON a.ID_Anggota = p.ID_Anggota
WHERE p.ID_Peminjaman IS NULL;

-- Buku yang belum pernah dipinjam
SELECT b.Judul, b.Penulis
FROM Buku b
LEFT JOIN Peminjaman p ON b.ID_Buku = p.ID_Buku
WHERE p.ID_Peminjaman IS NULL;


-- ============================================================
--  BAGIAN 4 - PENGUJIAN INDEKS
--  Menggunakan EXPLAIN untuk cek apakah indeks dipakai
-- ============================================================

-- Cek apakah query menggunakan index
EXPLAIN SELECT * FROM Buku WHERE Penulis = 'Budi';
EXPLAIN SELECT * FROM Anggota WHERE Nama = 'Andi';
EXPLAIN SELECT * FROM Peminjaman WHERE Tanggal_Pinjam = '2024-01-01';


-- ============================================================
--  BAGIAN 5 - PENGUJIAN TRANSAKSI (ACID)
--  Memastikan transaksi bekerja dengan benar
-- ============================================================

-- Contoh transaksi: pinjam buku (semua atau tidak sama sekali)
START TRANSACTION;

INSERT INTO Peminjaman (ID_Buku, ID_Anggota, Tanggal_Pinjam)
VALUES (1, 2, CURDATE());

-- Jika berhasil → COMMIT
COMMIT;

-- Jika gagal → ROLLBACK (uncomment baris ini)
-- ROLLBACK;


-- ============================================================
--  BAGIAN 6 - NORMALISASI CHECK
--  Memastikan tidak ada duplikasi data
-- ============================================================

-- Cek duplikasi judul buku
SELECT Judul, COUNT(*) AS jumlah
FROM Buku
GROUP BY Judul
HAVING COUNT(*) > 1;

-- Cek duplikasi nama anggota
SELECT Nama, COUNT(*) AS jumlah
FROM Anggota
GROUP BY Nama
HAVING COUNT(*) > 1;