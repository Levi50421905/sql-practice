-- ============================================================
-- File    : engineerl.sql
-- Topik   : Membuat Database - Insinyur Data Madya (Sesi 02)
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================

-- ============================================================
-- SECTION 1: SETUP DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS engineerl;
USE engineerl;


-- ============================================================
-- SECTION 2: DDL - CREATE TABLES
-- ============================================================

-- Tabel: engineers
-- Menyimpan data insinyur yang terlibat dalam proyek
CREATE TABLE IF NOT EXISTS engineers (
    engineer_id VARCHAR(10)  NOT NULL,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100),
    join_date   DATE,
    PRIMARY KEY (engineer_id)
);

-- Tabel: project
-- Menyimpan data proyek yang dikerjakan
-- Kolom 'name' ditambahkan via ALTER TABLE setelah CREATE (lihat bawah)
CREATE TABLE IF NOT EXISTS project (
    project_id VARCHAR(3)  NOT NULL,
    start_date DATE,
    end_date   DATE,
    PRIMARY KEY (project_id)
);

-- Menambahkan kolom name pada tabel project (ALTER TABLE)
ALTER TABLE project
    ADD COLUMN name VARCHAR(50) AFTER project_id;

-- Tabel: task
-- Menyimpan task/tugas yang berelasi ke project (Many-to-One)
CREATE TABLE IF NOT EXISTS task (
    task_id     VARCHAR(3)   NOT NULL,
    description VARCHAR(100),
    status      VARCHAR(50),
    due_date    DATE,
    project_id  VARCHAR(3),
    PRIMARY KEY (task_id),
    CONSTRAINT fk_task_project
        FOREIGN KEY (project_id) REFERENCES project (project_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- Tabel: engineer_projects (junction table - Many-to-Many)
-- Menghubungkan engineers dan project dengan atribut 'role'
CREATE TABLE IF NOT EXISTS engineer_projects (
    engineer_id VARCHAR(3)  NOT NULL,
    project_id  VARCHAR(3)  NOT NULL,
    role        VARCHAR(20),
    PRIMARY KEY (engineer_id, project_id),
    CONSTRAINT fk_ep_engineer
        FOREIGN KEY (engineer_id) REFERENCES engineers (engineer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_ep_project
        FOREIGN KEY (project_id) REFERENCES project (project_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- ============================================================
-- SECTION 3: DML - INSERT DATA
-- ============================================================

-- Data engineers
INSERT INTO engineers (engineer_id, name, email, join_date) VALUES
    ('E01', 'Levi',   'levialfarezzi@gmail.com', '2025-06-01'),
    ('E02', 'Mikasa', 'mikasa@gmail.com',         '2024-02-15'),
    ('E03', 'Armin',  'armin@gmail.com',           '2024-03-20');

-- Data project
INSERT INTO project (project_id, name, start_date, end_date) VALUES
    ('P01', 'AI Deployment',    '2024-04-01', '2024-06-30'),
    ('P02', 'Database Migration','2024-05-01', '2024-08-01');

-- Data task
INSERT INTO task (task_id, description, status, due_date, project_id) VALUES
    ('T01', 'Build model API',    'Pending',     '2024-06-01', 'P01'),
    ('T02', 'Prepare data schema','Done',         '2024-05-15', 'P01'),
    ('T03', 'Write test cases',   'In Progress', '2024-06-20', 'P02');

-- Data engineer_projects (junction)
INSERT INTO engineer_projects (engineer_id, project_id, role) VALUES
    ('E01', 'P01', 'Lead'),
    ('E02', 'P01', 'Developer'),
    ('E03', 'P02', 'Tester');


-- ============================================================
-- SECTION 4: DQL - SELECT / MENAMPILKAN DATA
-- ============================================================

-- 4.1 Tampilkan semua engineers
SELECT * FROM engineers;

-- 4.2 Tampilkan semua project
SELECT * FROM project;

-- 4.3 Tampilkan semua task
SELECT * FROM task;

-- 4.4 Tampilkan semua data engineer_projects
SELECT * FROM engineer_projects;

-- 4.5 Keterlibatan insinyur dalam proyek (JOIN 3 tabel)
SELECT
    e.name          AS NamaInsinyur,
    p.name          AS NamaProyek,
    ep.role         AS Peran
FROM engineer_projects ep
JOIN engineers e ON ep.engineer_id = e.engineer_id
JOIN project   p ON ep.project_id  = p.project_id
ORDER BY p.project_id, ep.role;

-- 4.6 Task per proyek beserta nama proyek (JOIN)
SELECT
    t.task_id,
    t.description,
    t.status,
    t.due_date,
    p.name AS NamaProyek
FROM task t
JOIN project p ON t.project_id = p.project_id
ORDER BY t.due_date;

-- 4.7 Hitung jumlah task per proyek
SELECT
    p.name          AS NamaProyek,
    COUNT(t.task_id) AS JumlahTask
FROM project p
LEFT JOIN task t ON p.project_id = t.project_id
GROUP BY p.project_id, p.name;

-- 4.8 Hitung jumlah insinyur per proyek
SELECT
    p.name           AS NamaProyek,
    COUNT(ep.engineer_id) AS JumlahInsinyur
FROM project p
LEFT JOIN engineer_projects ep ON p.project_id = ep.project_id
GROUP BY p.project_id, p.name;

-- 4.9 Insinyur yang bergabung setelah 2024-01-01
SELECT name, email, join_date
FROM engineers
WHERE join_date > '2024-01-01'
ORDER BY join_date;

-- 4.10 Task yang belum selesai (status bukan 'Done')
SELECT
    t.task_id,
    t.description,
    t.status,
    t.due_date,
    p.name AS NamaProyek
FROM task t
JOIN project p ON t.project_id = p.project_id
WHERE t.status != 'Done'
ORDER BY t.due_date;


-- ============================================================
-- SECTION 5: STRUKTUR TABEL (DESCRIBE)
-- ============================================================

DESCRIBE engineers;
DESCRIBE project;
DESCRIBE task;
DESCRIBE engineer_projects;

SHOW TABLES;