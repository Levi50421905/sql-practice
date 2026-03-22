-- ============================================================
-- File    : full_text_search.sql
-- Topik   : Full-Text Search — MATCH AGAINST, FULLTEXT INDEX
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL (InnoDB, MySQL 5.6+ / MariaDB 10.0+)
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- Full-Text Search (FTS) jauh lebih powerful dari LIKE '%kata%':
--   LIKE '%kata%'  → lambat (full table scan), tidak relevan
--   MATCH AGAINST  → pakai index khusus, ada skor relevansi
--
-- Mode pencarian:
--   IN NATURAL LANGUAGE MODE  → default, cari kata secara alami
--   IN BOOLEAN MODE           → operator +, -, *, "", ~
--   WITH QUERY EXPANSION      → perluas hasil berdasarkan hasil pertama
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS fts_demo;
USE fts_demo;

-- Tabel artikel blog
CREATE TABLE IF NOT EXISTS artikel (
    id_artikel  INT AUTO_INCREMENT PRIMARY KEY,
    judul       VARCHAR(255),
    konten      TEXT,
    kategori    VARCHAR(50),
    penulis     VARCHAR(100),
    tgl_terbit  DATE,
    FULLTEXT INDEX idx_ft_judul_konten (judul, konten),
    FULLTEXT INDEX idx_ft_judul (judul)
) ENGINE=InnoDB;

-- Tabel produk dengan deskripsi
CREATE TABLE IF NOT EXISTS produk (
    id_produk   INT AUTO_INCREMENT PRIMARY KEY,
    nama        VARCHAR(200),
    deskripsi   TEXT,
    kategori    VARCHAR(50),
    harga       INT,
    FULLTEXT INDEX idx_ft_produk (nama, deskripsi)
) ENGINE=InnoDB;

INSERT INTO artikel (judul, konten, kategori, penulis, tgl_terbit) VALUES
    ('Belajar SQL dari Nol',
     'SQL adalah bahasa query standar untuk database relasional. Dengan SQL kita bisa membuat tabel, memasukkan data, dan melakukan query SELECT untuk menampilkan data.',
     'Database', 'Levi', '2025-01-10'),

    ('Pengenalan MySQL dan MariaDB',
     'MySQL adalah sistem manajemen database relasional open source. MariaDB adalah fork dari MySQL yang dibuat oleh pengembang asli MySQL. Keduanya menggunakan sintaks SQL yang hampir sama.',
     'Database', 'Levi', '2025-01-15'),

    ('Tips Optimasi Query SQL',
     'Query SQL yang lambat bisa dipercepat dengan beberapa teknik: menambahkan index pada kolom yang sering dicari, menghindari SELECT *, menggunakan EXPLAIN untuk analisis query.',
     'Database', 'Andi', '2025-02-01'),

    ('Memahami JOIN di SQL',
     'JOIN digunakan untuk menggabungkan data dari dua atau lebih tabel. Jenis JOIN: INNER JOIN, LEFT JOIN, RIGHT JOIN, dan FULL OUTER JOIN. JOIN membutuhkan relasi foreign key.',
     'Database', 'Levi', '2025-02-10'),

    ('Belajar Python untuk Data Science',
     'Python adalah bahasa pemrograman yang populer untuk analisis data dan machine learning. Library seperti pandas, numpy, dan matplotlib sangat berguna untuk pengolahan data.',
     'Pemrograman', 'Budi', '2025-02-15'),

    ('Web Development dengan JavaScript',
     'JavaScript adalah bahasa pemrograman untuk web. Framework populer: React, Vue, Angular untuk frontend. Node.js untuk backend. TypeScript menambahkan tipe data statis ke JavaScript.',
     'Pemrograman', 'Citra', '2025-03-01'),

    ('Stored Procedure dan Trigger MySQL',
     'Stored Procedure adalah kumpulan perintah SQL yang disimpan di database dan bisa dipanggil berulang kali. Trigger otomatis berjalan saat terjadi INSERT, UPDATE, atau DELETE.',
     'Database', 'Levi', '2025-03-10'),

    ('Normalisasi Database: 1NF, 2NF, 3NF',
     'Normalisasi adalah proses mendesain database untuk menghilangkan redundansi data. First Normal Form mengharuskan nilai atomic. Second Normal Form menghilangkan partial dependency.',
     'Database', 'Andi', '2025-03-20'),

    ('Docker untuk Developer',
     'Docker adalah platform kontainerisasi yang memudahkan deployment aplikasi. Dengan Docker kita bisa membuat container yang konsisten di berbagai lingkungan: development, staging, production.',
     'DevOps', 'Dodi', '2025-04-01'),

    ('REST API dengan Node.js',
     'REST API adalah arsitektur web service yang menggunakan HTTP method: GET, POST, PUT, DELETE. Node.js dengan Express framework sangat populer untuk membuat REST API yang cepat.',
     'Pemrograman', 'Eko', '2025-04-10');

INSERT INTO produk (nama, deskripsi, kategori, harga) VALUES
    ('Laptop Gaming ASUS ROG',
     'Laptop gaming bertenaga tinggi dengan prosesor Intel Core i9, RAM 32GB DDR5, GPU NVIDIA RTX 4070. Cocok untuk gaming berat dan rendering 3D.',
     'Elektronik', 25000000),
    ('Laptop Bisnis ThinkPad',
     'Laptop bisnis ringan dengan baterai tahan lama 12 jam, layar IPS Full HD, keyboard ergonomis. Ideal untuk profesional dan pebisnis yang sering bepergian.',
     'Elektronik', 18000000),
    ('Mouse Gaming Logitech',
     'Mouse gaming dengan sensor optik presisi tinggi 25600 DPI, 11 tombol yang bisa dikustomisasi, RGB lighting. Cocok untuk gaming kompetitif.',
     'Elektronik', 850000),
    ('Keyboard Mekanikal Keychron',
     'Keyboard mekanikal compact tenkeyless dengan switch Cherry MX Red, backlight RGB, kompatibel Windows dan Mac. Ringan dan portabel untuk programmer.',
     'Elektronik', 1200000),
    ('Buku Clean Code',
     'Buku panduan menulis kode yang bersih dan mudah dibaca oleh Robert C. Martin. Membahas prinsip SOLID, refactoring, dan best practice pemrograman profesional.',
     'Buku', 185000),
    ('Buku SQL Tingkat Lanjut',
     'Buku lengkap belajar SQL dari dasar hingga tingkat lanjut: query kompleks, optimasi performa, stored procedure, trigger, dan administrasi database MySQL.',
     'Buku', 145000);


-- ============================================================
-- SECTION 2: NATURAL LANGUAGE MODE (default)
-- ============================================================
-- MySQL otomatis mengabaikan kata umum (stop words) seperti:
-- "yang", "dan", "di", "untuk", "adalah", "a", "the", "in", dll.

-- 2.1 Cari artikel yang mengandung kata "SQL"
SELECT id_artikel, judul, kategori,
       MATCH(judul, konten) AGAINST('SQL') AS skor
FROM artikel
WHERE MATCH(judul, konten) AGAINST('SQL')
ORDER BY skor DESC;

-- 2.2 Cari dengan beberapa kata (OR secara default)
SELECT id_artikel, judul,
       MATCH(judul, konten) AGAINST('database query') AS skor
FROM artikel
WHERE MATCH(judul, konten) AGAINST('database query')
ORDER BY skor DESC;

-- 2.3 Tampilkan skor relevansi tanpa filter (lihat semua skor)
SELECT id_artikel, judul,
       MATCH(judul, konten) AGAINST('SQL database') AS skor
FROM artikel
ORDER BY skor DESC;

-- 2.4 Cari produk dengan kata "gaming"
SELECT id_produk, nama, kategori, harga,
       MATCH(nama, deskripsi) AGAINST('gaming') AS skor
FROM produk
WHERE MATCH(nama, deskripsi) AGAINST('gaming')
ORDER BY skor DESC;


-- ============================================================
-- SECTION 3: BOOLEAN MODE
-- ============================================================
-- Operator Boolean:
--   +kata    → kata WAJIB ada
--   -kata    → kata TIDAK BOLEH ada
--   kata*    → wildcard (prefix search): "SQL*" cocok "SQL", "SQLite", "SQLServer"
--   "frasa"  → frasa harus tepat
--   ~kata    → kurangi relevansi jika ada kata ini
--   >kata    → naikkan relevansi
--   <kata    → turunkan relevansi

-- 3.1 Wajib ada "SQL", tidak boleh ada "Python"
SELECT id_artikel, judul
FROM artikel
WHERE MATCH(judul, konten) AGAINST('+SQL -Python' IN BOOLEAN MODE);

-- 3.2 Wajib ada "database" DAN "query"
SELECT id_artikel, judul
FROM artikel
WHERE MATCH(judul, konten) AGAINST('+database +query' IN BOOLEAN MODE);

-- 3.3 Prefix search: cari semua yang diawali "data"
SELECT id_artikel, judul
FROM artikel
WHERE MATCH(judul, konten) AGAINST('data*' IN BOOLEAN MODE);

-- 3.4 Frasa exact: cari "stored procedure" sebagai frasa utuh
SELECT id_artikel, judul
FROM artikel
WHERE MATCH(judul, konten) AGAINST('"stored procedure"' IN BOOLEAN MODE);

-- 3.5 Kombinasi: wajib ada "SQL", naikkan relevansi jika ada "optimasi"
SELECT id_artikel, judul,
       MATCH(judul, konten) AGAINST('+SQL >optimasi' IN BOOLEAN MODE) AS skor
FROM artikel
WHERE MATCH(judul, konten) AGAINST('+SQL >optimasi' IN BOOLEAN MODE)
ORDER BY skor DESC;

-- 3.6 Cari produk laptop tapi bukan gaming
SELECT nama, harga
FROM produk
WHERE MATCH(nama, deskripsi) AGAINST('+laptop -gaming' IN BOOLEAN MODE);


-- ============================================================
-- SECTION 4: WITH QUERY EXPANSION
-- ============================================================
-- Dua tahap:
--   1. Cari hasil awal dengan kata kunci
--   2. Ambil kata-kata dari hasil awal, perluas pencarian
-- Berguna untuk cari topik yang berkaitan.

SELECT id_artikel, judul,
       MATCH(judul, konten) AGAINST('SQL' WITH QUERY EXPANSION) AS skor
FROM artikel
ORDER BY skor DESC
LIMIT 5;


-- ============================================================
-- SECTION 5: FTS vs LIKE — PERBANDINGAN
-- ============================================================

-- 5.1 LIKE (lambat untuk data besar, tidak ada skor relevansi)
SELECT id_artikel, judul
FROM artikel
WHERE judul LIKE '%SQL%' OR konten LIKE '%SQL%';

-- 5.2 MATCH AGAINST (cepat karena pakai index, ada skor relevansi)
SELECT id_artikel, judul,
       MATCH(judul, konten) AGAINST('SQL') AS relevansi
FROM artikel
WHERE MATCH(judul, konten) AGAINST('SQL')
ORDER BY relevansi DESC;

-- Kapan pakai LIKE vs FTS?
-- LIKE  → kolom VARCHAR pendek, pattern bukan kata (misal: kode, nomor)
-- FTS   → kolom TEXT/VARCHAR panjang, pencarian kata, butuh relevansi


-- ============================================================
-- SECTION 6: MANAJEMEN FULLTEXT INDEX
-- ============================================================

-- 6.1 Tambah FULLTEXT index pada tabel yang sudah ada
ALTER TABLE artikel ADD FULLTEXT INDEX idx_ft_penulis (penulis);

-- 6.2 Lihat semua index di tabel
SHOW INDEX FROM artikel;
SHOW INDEX FROM produk;

-- 6.3 Hapus FULLTEXT index
ALTER TABLE artikel DROP INDEX idx_ft_penulis;

-- 6.4 Cek variabel FTS
SHOW VARIABLES LIKE 'ft_min_word_len';      -- panjang kata minimum (default: 4)
SHOW VARIABLES LIKE 'innodb_ft_min_token_size'; -- InnoDB (default: 3)
-- Kata lebih pendek dari minimum diabaikan FTS
-- Untuk cari kata 3 huruf ("SQL"), set innodb_ft_min_token_size = 3