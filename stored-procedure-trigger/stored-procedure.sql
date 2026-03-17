-- ============================================================
--  Project   : Stored Procedure - Studi Kasus Perpustakaan
--  Author    : Levi Alfarezzi (Muhammad Alfarezzi Fallevi)
--  Mata Kuliah: Insinyur Data Madya
--  Database  : MySQL / MariaDB
-- ============================================================

USE Perpustakaan;


-- ============================================================
--  TABEL PENDUKUNG
-- ============================================================

-- Tabel stock_alerts untuk menyimpan peringatan stok buku
CREATE TABLE IF NOT EXISTS stock_alerts (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    book_id     INT,
    book_title  VARCHAR(255),
    curr_stock  INT,
    alert_date  DATETIME DEFAULT NOW()
);


-- ============================================================
--  STORED PROCEDURE 1
--  GetBorrowedBooksByMonth
--  Memeriksa buku yang dipinjam pada bulan tertentu
-- ============================================================

DELIMITER //

CREATE PROCEDURE GetBorrowedBooksByMonth(
    IN input_month INT,
    IN input_year  INT
)
BEGIN
    SELECT
        p.ID_Peminjaman,
        b.Judul          AS judul_buku,
        b.Penulis,
        a.Nama           AS nama_anggota,
        p.Tanggal_Pinjam,
        p.Tanggal_Kembali,
        CASE
            WHEN p.Tanggal_Kembali IS NULL THEN 'Belum Dikembalikan'
            ELSE 'Sudah Dikembalikan'
        END AS status
    FROM Peminjaman p
    INNER JOIN Buku    b ON p.ID_Buku    = b.ID_Buku
    INNER JOIN Anggota a ON p.ID_Anggota = a.ID_Anggota
    WHERE MONTH(p.Tanggal_Pinjam) = input_month
      AND YEAR(p.Tanggal_Pinjam)  = input_year
    ORDER BY p.Tanggal_Pinjam DESC;
END //

DELIMITER ;


-- ============================================================
--  STORED PROCEDURE 2
--  CheckBookStockAndAlert
--  Memeriksa stok buku dan kirim peringatan jika stok kurang
-- ============================================================

DELIMITER //

CREATE PROCEDURE CheckBookStockAndAlert()
BEGIN
    DECLARE low_stock_threshold INT DEFAULT 3; -- batas stok rendah
    DECLARE finished            INT DEFAULT 0;
    DECLARE v_book_id           INT;
    DECLARE v_book_title        VARCHAR(255);
    DECLARE v_curr_stock        INT;

    -- Cursor untuk iterasi buku dengan stok rendah
    DECLARE cur CURSOR FOR
        SELECT ID_Buku, Judul, stock
        FROM Buku
        WHERE stock < low_stock_threshold;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_book_id, v_book_title, v_curr_stock;

        IF finished THEN
            LEAVE read_loop;
        END IF;

        -- Sisipkan peringatan ke tabel stock_alerts
        INSERT INTO stock_alerts (book_id, book_title, curr_stock, alert_date)
        VALUES (v_book_id, v_book_title, v_curr_stock, NOW());

    END LOOP;

    CLOSE cur;

    -- Tampilkan hasil peringatan yang baru ditambahkan
    SELECT * FROM stock_alerts ORDER BY alert_date DESC LIMIT 10;

END //

DELIMITER ;


-- ============================================================
--  CARA MEMANGGIL STORED PROCEDURE
-- ============================================================

-- Panggil SP 1: buku yang dipinjam bulan Januari 2024
CALL GetBorrowedBooksByMonth(1, 2024);

-- Panggil SP 2: cek stok dan buat peringatan
CALL CheckBookStockAndAlert();

-- Lihat semua peringatan stok
SELECT * FROM stock_alerts;

-- Hapus stored procedure jika ingin dibuat ulang
-- DROP PROCEDURE IF EXISTS GetBorrowedBooksByMonth;
-- DROP PROCEDURE IF EXISTS CheckBookStockAndAlert;