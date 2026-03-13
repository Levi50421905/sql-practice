-- ============================================================
--  Project   : Library Database (Perpustakaan)
--  Author    : Levi Alfarezzi
--  Database  : PostgreSQL
--  Created   : 2025
-- ============================================================


-- ============================================================
--  TABLES
-- ============================================================

-- Members (Anggota)
CREATE TABLE members (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    phone       VARCHAR(20),
    address     TEXT,
    joined_at   DATE DEFAULT CURRENT_DATE
);

-- Authors (Penulis)
CREATE TABLE authors (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    nationality VARCHAR(50)
);

-- Categories (Kategori Buku)
CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL
);

-- Books (Buku)
CREATE TABLE books (
    id           SERIAL PRIMARY KEY,
    author_id    INT REFERENCES authors(id) ON DELETE SET NULL,
    category_id  INT REFERENCES categories(id) ON DELETE SET NULL,
    title        VARCHAR(200) NOT NULL,
    isbn         VARCHAR(20) UNIQUE,
    published    INT,
    stock        INT DEFAULT 1 CHECK (stock >= 0)
);

-- Loans (Peminjaman)
CREATE TABLE loans (
    id           SERIAL PRIMARY KEY,
    member_id    INT REFERENCES members(id) ON DELETE CASCADE,
    book_id      INT REFERENCES books(id) ON DELETE CASCADE,
    loan_date    DATE DEFAULT CURRENT_DATE,
    due_date     DATE DEFAULT (CURRENT_DATE + INTERVAL '7 days'),
    return_date  DATE,
    status       VARCHAR(20) DEFAULT 'borrowed'
                   CHECK (status IN ('borrowed', 'returned', 'overdue'))
);


-- ============================================================
--  INDEXES
-- ============================================================

CREATE INDEX idx_books_author   ON books(author_id);
CREATE INDEX idx_books_category ON books(category_id);
CREATE INDEX idx_loans_member   ON loans(member_id);
CREATE INDEX idx_loans_book     ON loans(book_id);


-- ============================================================
--  SEED DATA
-- ============================================================

INSERT INTO authors (name, nationality) VALUES
  ('Andrea Hirata',       'Indonesia'),
  ('Pramoedya Ananta T.', 'Indonesia'),
  ('J.K. Rowling',        'British'),
  ('Robert C. Martin',    'American'),
  ('Raditya Dika',        'Indonesia');

INSERT INTO categories (name) VALUES
  ('Novel'),
  ('Pemrograman'),
  ('Biografi'),
  ('Komedi'),
  ('Sejarah');

INSERT INTO books (author_id, category_id, title, isbn, published, stock) VALUES
  (1, 1, 'Laskar Pelangi',              '978-979-1290-41-7', 2005, 3),
  (1, 1, 'Sang Pemimpi',                '978-979-1290-42-4', 2006, 2),
  (2, 5, 'Bumi Manusia',                '978-979-1290-10-3', 1980, 2),
  (3, 1, 'Harry Potter and the Philosopher''s Stone', '978-0-7475-3269-9', 1997, 1),
  (4, 2, 'Clean Code',                  '978-0-13-235088-4', 2008, 2),
  (5, 4, 'Kambing Jantan',              '978-979-1290-55-4', 2005, 3);

INSERT INTO members (name, email, phone, joined_at) VALUES
  ('Levi Alfarezzi', 'levi@email.com',  '081234567890', '2024-01-10'),
  ('Budi Santoso',   'budi@email.com',  '082345678901', '2024-03-15'),
  ('Siti Rahayu',    'siti@email.com',  '083456789012', '2024-06-20'),
  ('Andi Pratama',   'andi@email.com',  '084567890123', '2025-01-05'),
  ('Dewi Lestari',   'dewi@email.com',  '085678901234', '2025-02-14');

INSERT INTO loans (member_id, book_id, loan_date, due_date, return_date, status) VALUES
  (1, 1, '2025-01-01', '2025-01-08', '2025-01-07', 'returned'),
  (2, 3, '2025-01-10', '2025-01-17', NULL,          'borrowed'),
  (3, 5, '2025-01-12', '2025-01-19', '2025-01-18', 'returned'),
  (4, 2, '2025-02-01', '2025-02-08', NULL,          'overdue'),
  (5, 4, '2025-02-10', '2025-02-17', NULL,          'borrowed'),
  (1, 6, '2025-03-01', '2025-03-08', NULL,          'borrowed');