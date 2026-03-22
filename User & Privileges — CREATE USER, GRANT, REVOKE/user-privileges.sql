-- ============================================================
-- File    : user_privileges.sql
-- Topik   : User & Privileges — CREATE USER, GRANT, REVOKE
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- DCL (Data Control Language) mengatur HAK AKSES user ke database.
-- Perintah utama: CREATE USER, GRANT, REVOKE, DROP USER, SHOW GRANTS
-- ============================================================


-- ============================================================
-- SECTION 1: MEMBUAT USER
-- ============================================================

-- Format: CREATE USER 'username'@'host' IDENTIFIED BY 'password';
-- host: 'localhost' = hanya dari mesin lokal
--       '%'         = dari mana saja (remote)
--       '192.168.1.%' = dari subnet tertentu

CREATE USER IF NOT EXISTS 'admin_db'@'localhost'     IDENTIFIED BY 'Admin@1234';
CREATE USER IF NOT EXISTS 'developer'@'localhost'    IDENTIFIED BY 'Dev@1234';
CREATE USER IF NOT EXISTS 'analis'@'localhost'       IDENTIFIED BY 'Analis@1234';
CREATE USER IF NOT EXISTS 'readonly_user'@'%'        IDENTIFIED BY 'Read@1234';
CREATE USER IF NOT EXISTS 'backup_user'@'localhost'  IDENTIFIED BY 'Backup@1234';

-- Cek user yang sudah ada
SELECT user, host FROM mysql.user WHERE user NOT LIKE 'mysql%';


-- ============================================================
-- SECTION 2: GRANT — MEMBERIKAN HAK AKSES
-- ============================================================
-- Format: GRANT hak_akses ON database.tabel TO 'user'@'host';
-- Hak akses: SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALL PRIVILEGES, dll.

-- 2.1 admin_db → semua hak akses ke semua database
GRANT ALL PRIVILEGES ON *.* TO 'admin_db'@'localhost' WITH GRANT OPTION;
-- WITH GRANT OPTION: user ini bisa memberikan hak ke user lain

-- 2.2 developer → akses penuh ke database poliklinik dan ecommerce_db
GRANT ALL PRIVILEGES ON poliklinik.*    TO 'developer'@'localhost';
GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'developer'@'localhost';

-- 2.3 analis → hanya SELECT (baca saja) ke semua database
GRANT SELECT ON *.* TO 'analis'@'localhost';

-- 2.4 readonly_user → SELECT ke tabel tertentu saja
GRANT SELECT ON ecommerce_db.Produk      TO 'readonly_user'@'%';
GRANT SELECT ON ecommerce_db.Transaksi   TO 'readonly_user'@'%';
GRANT SELECT ON poliklinik.Pasien        TO 'readonly_user'@'%';

-- 2.5 backup_user → hak khusus untuk backup
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'backup_user'@'localhost';

-- Terapkan perubahan privilege (wajib setelah GRANT/REVOKE)
FLUSH PRIVILEGES;


-- ============================================================
-- SECTION 3: SHOW GRANTS — CEK HAK AKSES
-- ============================================================

SHOW GRANTS FOR 'admin_db'@'localhost';
SHOW GRANTS FOR 'developer'@'localhost';
SHOW GRANTS FOR 'analis'@'localhost';
SHOW GRANTS FOR 'readonly_user'@'%';
SHOW GRANTS FOR 'backup_user'@'localhost';

-- Cek hak akses user yang sedang login
SHOW GRANTS FOR CURRENT_USER();


-- ============================================================
-- SECTION 4: REVOKE — MENCABUT HAK AKSES
-- ============================================================
-- Format: REVOKE hak_akses ON database.tabel FROM 'user'@'host';

-- 4.1 Cabut DELETE dan DROP dari developer di poliklinik
REVOKE DELETE, DROP ON poliklinik.* FROM 'developer'@'localhost';

-- 4.2 Cabut akses ke tabel Pasien dari readonly_user
REVOKE SELECT ON poliklinik.Pasien FROM 'readonly_user'@'%';

-- 4.3 Cabut WITH GRANT OPTION dari admin_db
REVOKE GRANT OPTION ON *.* FROM 'admin_db'@'localhost';

FLUSH PRIVILEGES;

-- Verifikasi setelah revoke
SHOW GRANTS FOR 'developer'@'localhost';
SHOW GRANTS FOR 'readonly_user'@'%';


-- ============================================================
-- SECTION 5: MENGUBAH PASSWORD USER
-- ============================================================

-- MySQL 8.0+ / MariaDB 10.4+
ALTER USER 'developer'@'localhost' IDENTIFIED BY 'NewDev@5678';

-- MariaDB (alternatif)
-- SET PASSWORD FOR 'developer'@'localhost' = PASSWORD('NewDev@5678');

FLUSH PRIVILEGES;


-- ============================================================
-- SECTION 6: ROLE (MariaDB 10.0+ / MySQL 8.0+)
-- ============================================================
-- Role = kumpulan privilege yang bisa diberikan ke banyak user sekaligus.

-- Buat role
CREATE ROLE IF NOT EXISTS 'role_developer';
CREATE ROLE IF NOT EXISTS 'role_analis';
CREATE ROLE IF NOT EXISTS 'role_readonly';

-- Assign privilege ke role
GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'role_developer';
GRANT SELECT ON *.* TO 'role_analis';
GRANT SELECT ON ecommerce_db.Produk TO 'role_readonly';
GRANT SELECT ON ecommerce_db.Transaksi TO 'role_readonly';

-- Assign role ke user
GRANT 'role_developer' TO 'developer'@'localhost';
GRANT 'role_analis'    TO 'analis'@'localhost';
GRANT 'role_readonly'  TO 'readonly_user'@'%';

-- Aktifkan role sebagai default saat login
SET DEFAULT ROLE 'role_developer' FOR 'developer'@'localhost';
SET DEFAULT ROLE 'role_analis'    FOR 'analis'@'localhost';

FLUSH PRIVILEGES;

-- Cek role
SELECT * FROM information_schema.APPLICABLE_ROLES;


-- ============================================================
-- SECTION 7: MENGHAPUS USER
-- ============================================================

-- Hapus user (otomatis mencabut semua privilege-nya)
DROP USER IF EXISTS 'readonly_user'@'%';
DROP USER IF EXISTS 'backup_user'@'localhost';

-- Verifikasi
SELECT user, host FROM mysql.user WHERE user NOT LIKE 'mysql%';


-- ============================================================
-- SECTION 8: RINGKASAN HAK AKSES (REFERENSI)
-- ============================================================
-- Hak akses yang umum dipakai:
--
-- DATA:
--   SELECT          → baca data
--   INSERT          → tambah data
--   UPDATE          → ubah data
--   DELETE          → hapus baris
--
-- STRUKTUR:
--   CREATE          → buat database/tabel
--   ALTER           → ubah struktur tabel
--   DROP            → hapus database/tabel
--   INDEX           → buat/hapus index
--
-- ADMIN:
--   ALL PRIVILEGES  → semua hak akses
--   GRANT OPTION    → bisa kasih hak ke user lain
--   SUPER           → operasi admin (KILL query, SET GLOBAL, dll)
--   LOCK TABLES     → kunci tabel (untuk backup)
--   SHOW DATABASES  → lihat semua database
--
-- CONTOH SKENARIO:
--   Junior dev   → SELECT, INSERT, UPDATE pada db tertentu
--   Senior dev   → + CREATE, ALTER, DELETE
--   DBA          → ALL PRIVILEGES
--   Data analyst → SELECT saja (*./*)
--   Backup agent → SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER