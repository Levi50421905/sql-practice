-- ============================================================
--  Project   : Library Database - Practice Queries
--  Author    : Levi Alfarezzi
--  Database  : PostgreSQL
-- ============================================================


-- ============================================================
--  BAGIAN 1 - QUERY DASAR (SELECT, WHERE, ORDER BY)
-- ============================================================

-- 1. Tampilkan semua buku
SELECT * FROM books;

-- 2. Tampilkan semua anggota, urutkan berdasarkan nama
SELECT name, email, phone
FROM members
ORDER BY name ASC;

-- 3. Cari buku yang stoknya masih tersedia
SELECT title, stock
FROM books
WHERE stock > 0
ORDER BY title;

-- 4. Cari buku yang terbit setelah tahun 2000
SELECT title, published
FROM books
WHERE published > 2000
ORDER BY published DESC;

-- 5. Cari anggota yang bergabung di tahun 2025
SELECT name, joined_at
FROM members
WHERE EXTRACT(YEAR FROM joined_at) = 2025;

-- 6. Tampilkan peminjaman yang belum dikembalikan
SELECT *
FROM loans
WHERE return_date IS NULL
ORDER BY due_date ASC;

-- 7. Cari peminjaman dengan status overdue
SELECT *
FROM loans
WHERE status = 'overdue';

-- 8. Tampilkan 3 buku terbaru berdasarkan tahun terbit
SELECT title, published
FROM books
ORDER BY published DESC
LIMIT 3;


-- ============================================================
--  BAGIAN 2 - JOIN
-- ============================================================

-- 9. INNER JOIN — Tampilkan buku beserta nama penulisnya
SELECT 
    b.title,
    a.name   AS author,
    b.published
FROM books b
INNER JOIN authors a ON b.author_id = a.id
ORDER BY b.title;

-- 10. INNER JOIN — Tampilkan buku beserta kategorinya
SELECT 
    b.title,
    c.name   AS category,
    b.stock
FROM books b
INNER JOIN categories c ON b.category_id = c.id
ORDER BY c.name;

-- 11. INNER JOIN 3 tabel — Buku lengkap dengan penulis dan kategori
SELECT 
    b.title,
    a.name   AS author,
    c.name   AS category,
    b.published,
    b.stock
FROM books b
INNER JOIN authors a   ON b.author_id   = a.id
INNER JOIN categories c ON b.category_id = c.id
ORDER BY b.title;

-- 12. INNER JOIN — Siapa meminjam buku apa?
SELECT 
    m.name       AS member,
    b.title      AS book,
    l.loan_date,
    l.due_date,
    l.status
FROM loans l
INNER JOIN members m ON l.member_id = m.id
INNER JOIN books   b ON l.book_id   = b.id
ORDER BY l.loan_date DESC;

-- 13. LEFT JOIN — Semua anggota, termasuk yang belum pernah meminjam
SELECT 
    m.name,
    m.email,
    l.loan_date,
    l.status
FROM members m
LEFT JOIN loans l ON m.id = l.member_id
ORDER BY m.name;

-- 14. LEFT JOIN — Semua buku, termasuk yang belum pernah dipinjam
SELECT 
    b.title,
    a.name       AS author,
    l.loan_date,
    l.status
FROM books b
LEFT JOIN authors a ON b.author_id = a.id
LEFT JOIN loans   l ON b.id        = l.book_id
ORDER BY b.title;

-- 15. Anggota yang sedang meminjam buku (status 'borrowed' atau 'overdue')
SELECT 
    m.name       AS member,
    b.title      AS book,
    l.due_date,
    l.status
FROM loans l
INNER JOIN members m ON l.member_id = m.id
INNER JOIN books   b ON l.book_id   = b.id
WHERE l.status IN ('borrowed', 'overdue')
ORDER BY l.due_date ASC;

-- 16. Buku yang ditulis oleh penulis Indonesia
SELECT 
    b.title,
    a.name        AS author,
    a.nationality
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE a.nationality = 'Indonesia'
ORDER BY b.title;

-- 17. Anggota yang pernah meminjam lebih dari 1 buku
SELECT 
    m.name,
    COUNT(l.id) AS total_loans
FROM loans l
INNER JOIN members m ON l.member_id = m.id
GROUP BY m.id, m.name
HAVING COUNT(l.id) > 1
ORDER BY total_loans DESC;