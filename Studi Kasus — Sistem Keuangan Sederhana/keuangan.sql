-- ============================================================
-- File    : keuangan.sql
-- Topik   : Studi Kasus — Sistem Keuangan Sederhana
-- Author  : Muhammad Alfarezzi Fallevi (50421905)
-- DB      : MariaDB / MySQL
-- Repo    : github.com/Levi50421905/sql-practice
-- ============================================================
-- Sistem pencatatan keuangan: akun, jurnal umum (double entry),
-- laporan saldo, laba rugi, dan neraca sederhana.
-- ============================================================


-- ============================================================
-- SECTION 1: SETUP & DDL
-- ============================================================

CREATE DATABASE IF NOT EXISTS keuangan_db;
USE keuangan_db;

-- Kategori akun (untuk laporan keuangan)
CREATE TABLE IF NOT EXISTS Kategori_Akun (
    id_kategori  VARCHAR(10) PRIMARY KEY,
    nama         VARCHAR(100),
    tipe         ENUM('Aset','Kewajiban','Modal','Pendapatan','Beban'),
    normal_saldo ENUM('Debit','Kredit')
);

-- Chart of Accounts (daftar akun)
CREATE TABLE IF NOT EXISTS Akun (
    id_akun      VARCHAR(10) PRIMARY KEY,
    nama_akun    VARCHAR(100),
    id_kategori  VARCHAR(10),
    FOREIGN KEY (id_kategori) REFERENCES Kategori_Akun(id_kategori)
);

-- Jurnal umum header
CREATE TABLE IF NOT EXISTS Jurnal (
    id_jurnal    VARCHAR(10) PRIMARY KEY,
    tgl_jurnal   DATE,
    deskripsi    VARCHAR(255),
    referensi    VARCHAR(50) NULL
);

-- Jurnal detail (double-entry: setiap transaksi min 1 debit + 1 kredit)
CREATE TABLE IF NOT EXISTS Detail_Jurnal (
    id_detail   INT AUTO_INCREMENT PRIMARY KEY,
    id_jurnal   VARCHAR(10),
    id_akun     VARCHAR(10),
    debit       BIGINT DEFAULT 0,
    kredit      BIGINT DEFAULT 0,
    FOREIGN KEY (id_jurnal) REFERENCES Jurnal(id_jurnal),
    FOREIGN KEY (id_akun)   REFERENCES Akun(id_akun)
);


-- ============================================================
-- SECTION 2: INSERT DATA
-- ============================================================

INSERT INTO Kategori_Akun VALUES
    ('KA01','Aset Lancar',       'Aset',       'Debit'),
    ('KA02','Aset Tetap',        'Aset',       'Debit'),
    ('KA03','Kewajiban Lancar',  'Kewajiban',  'Kredit'),
    ('KA04','Modal',             'Modal',      'Kredit'),
    ('KA05','Pendapatan',        'Pendapatan', 'Kredit'),
    ('KA06','Beban Operasional', 'Beban',      'Debit'),
    ('KA07','Harga Pokok Penjualan','Beban',   'Debit');

INSERT INTO Akun VALUES
    ('1-001','Kas',                     'KA01'),
    ('1-002','Bank BCA',                'KA01'),
    ('1-003','Piutang Usaha',           'KA01'),
    ('1-004','Persediaan Barang',       'KA01'),
    ('1-005','Perlengkapan Kantor',     'KA01'),
    ('2-001','Peralatan & Mesin',       'KA02'),
    ('2-002','Akumulasi Penyusutan',    'KA02'),
    ('3-001','Hutang Usaha',            'KA03'),
    ('3-002','Hutang Gaji',             'KA03'),
    ('4-001','Modal Pemilik',           'KA04'),
    ('4-002','Laba Ditahan',            'KA04'),
    ('5-001','Pendapatan Penjualan',    'KA05'),
    ('5-002','Pendapatan Jasa',         'KA05'),
    ('6-001','Harga Pokok Penjualan',   'KA07'),
    ('6-002','Beban Gaji',              'KA06'),
    ('6-003','Beban Sewa Gedung',       'KA06'),
    ('6-004','Beban Utilitas',          'KA06'),
    ('6-005','Beban Penyusutan',        'KA06'),
    ('6-006','Beban Pemasaran',         'KA06');

-- Jurnal Umum Bulan Juni 2025
INSERT INTO Jurnal VALUES
    ('JRN001','2025-06-01','Setoran modal awal pemilik',NULL),
    ('JRN002','2025-06-02','Pembelian peralatan kantor - tunai',NULL),
    ('JRN003','2025-06-03','Pembelian persediaan barang dari supplier',NULL),
    ('JRN004','2025-06-05','Penjualan barang tunai',NULL),
    ('JRN005','2025-06-07','Penjualan barang kredit (piutang)',NULL),
    ('JRN006','2025-06-10','Penerimaan jasa konsultasi',NULL),
    ('JRN007','2025-06-12','Pembayaran sewa gedung bulan Juni',NULL),
    ('JRN008','2025-06-15','Pembayaran gaji karyawan',NULL),
    ('JRN009','2025-06-18','Pembayaran tagihan listrik & internet',NULL),
    ('JRN010','2025-06-20','Penerimaan pembayaran piutang',NULL),
    ('JRN011','2025-06-22','Pembayaran hutang ke supplier',NULL),
    ('JRN012','2025-06-25','Biaya pemasaran & iklan',NULL),
    ('JRN013','2025-06-30','Penyusutan peralatan bulan Juni',NULL),
    ('JRN014','2025-06-30','Penjualan akhir bulan',NULL);

INSERT INTO Detail_Jurnal (id_jurnal, id_akun, debit, kredit) VALUES
    -- JRN001: Modal masuk → Kas naik, Modal naik
    ('JRN001','1-001', 50000000, 0), ('JRN001','4-001', 0, 50000000),
    -- JRN002: Beli peralatan tunai → Peralatan naik, Kas turun
    ('JRN002','2-001', 15000000, 0), ('JRN002','1-001', 0, 15000000),
    -- JRN003: Beli persediaan kredit → Persediaan naik, Hutang naik
    ('JRN003','1-004', 20000000, 0), ('JRN003','3-001', 0, 20000000),
    -- JRN004: Jual barang tunai → Kas naik, Pendapatan naik + HPP naik, Persediaan turun
    ('JRN004','1-001', 8500000,  0), ('JRN004','5-001', 0, 8500000),
    ('JRN004','6-001', 5000000,  0), ('JRN004','1-004', 0, 5000000),
    -- JRN005: Jual kredit → Piutang naik, Pendapatan naik + HPP
    ('JRN005','1-003', 12000000, 0), ('JRN005','5-001', 0, 12000000),
    ('JRN005','6-001', 7000000,  0), ('JRN005','1-004', 0, 7000000),
    -- JRN006: Jasa konsultasi tunai
    ('JRN006','1-001', 5000000,  0), ('JRN006','5-002', 0, 5000000),
    -- JRN007: Bayar sewa
    ('JRN007','6-003', 3000000,  0), ('JRN007','1-002', 0, 3000000),
    -- JRN008: Bayar gaji
    ('JRN008','6-002', 8000000,  0), ('JRN008','1-002', 0, 8000000),
    -- JRN009: Bayar utilitas
    ('JRN009','6-004', 750000,   0), ('JRN009','1-002', 0, 750000),
    -- JRN010: Terima pembayaran piutang
    ('JRN010','1-002', 12000000, 0), ('JRN010','1-003', 0, 12000000),
    -- JRN011: Bayar hutang supplier
    ('JRN011','3-001', 10000000, 0), ('JRN011','1-002', 0, 10000000),
    -- JRN012: Biaya marketing
    ('JRN012','6-006', 1500000,  0), ('JRN012','1-001', 0, 1500000),
    -- JRN013: Penyusutan (15jt / 60 bulan = 250rb/bulan)
    ('JRN013','6-005', 250000,   0), ('JRN013','2-002', 0, 250000),
    -- JRN014: Penjualan akhir bulan
    ('JRN014','1-001', 6000000,  0), ('JRN014','5-001', 0, 6000000),
    ('JRN014','6-001', 3500000,  0), ('JRN014','1-004', 0, 3500000);


-- ============================================================
-- SECTION 3: LAPORAN KEUANGAN
-- ============================================================

-- 3.1 Buku Besar per Akun (semua transaksi per akun)
SELECT
    a.id_akun, a.nama_akun, ka.tipe,
    j.tgl_jurnal, j.deskripsi,
    dj.debit, dj.kredit,
    SUM(dj.debit - dj.kredit) OVER (
        PARTITION BY a.id_akun
        ORDER BY j.tgl_jurnal, j.id_jurnal
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS saldo_berjalan
FROM Detail_Jurnal dj
JOIN Akun a  ON dj.id_akun   = a.id_akun
JOIN Jurnal j ON dj.id_jurnal = j.id_jurnal
JOIN Kategori_Akun ka ON a.id_kategori = ka.id_kategori
ORDER BY a.id_akun, j.tgl_jurnal;

-- 3.2 Neraca Saldo (Trial Balance)
SELECT
    a.id_akun,
    a.nama_akun,
    ka.tipe,
    ka.normal_saldo,
    SUM(dj.debit)  AS total_debit,
    SUM(dj.kredit) AS total_kredit,
    CASE ka.normal_saldo
        WHEN 'Debit'  THEN SUM(dj.debit) - SUM(dj.kredit)
        WHEN 'Kredit' THEN SUM(dj.kredit) - SUM(dj.debit)
    END AS saldo
FROM Detail_Jurnal dj
JOIN Akun a          ON dj.id_akun     = a.id_akun
JOIN Kategori_Akun ka ON a.id_kategori = ka.id_kategori
GROUP BY a.id_akun, a.nama_akun, ka.tipe, ka.normal_saldo
ORDER BY a.id_akun;

-- 3.3 Laporan Laba Rugi (Income Statement) bulan Juni 2025
WITH saldo_akun AS (
    SELECT
        a.id_akun, a.nama_akun, ka.tipe, ka.normal_saldo,
        CASE ka.normal_saldo
            WHEN 'Debit'  THEN SUM(dj.debit) - SUM(dj.kredit)
            WHEN 'Kredit' THEN SUM(dj.kredit) - SUM(dj.debit)
        END AS saldo
    FROM Detail_Jurnal dj
    JOIN Akun a          ON dj.id_akun     = a.id_akun
    JOIN Jurnal j         ON dj.id_jurnal   = j.id_jurnal
    JOIN Kategori_Akun ka ON a.id_kategori  = ka.id_kategori
    WHERE j.tgl_jurnal BETWEEN '2025-06-01' AND '2025-06-30'
    GROUP BY a.id_akun, a.nama_akun, ka.tipe, ka.normal_saldo
)
SELECT
    nama_akun,
    tipe,
    saldo,
    CASE WHEN tipe = 'Pendapatan' THEN saldo ELSE 0 END AS pendapatan,
    CASE WHEN tipe IN ('Beban','Harga Pokok Penjualan') THEN saldo ELSE 0 END AS beban
FROM saldo_akun
WHERE tipe IN ('Pendapatan','Beban','Harga Pokok Penjualan') AND saldo > 0
ORDER BY tipe, nama_akun;

-- 3.4 Ringkasan Laba Rugi
WITH saldo_akun AS (
    SELECT ka.tipe,
        CASE ka.normal_saldo
            WHEN 'Debit'  THEN SUM(dj.debit) - SUM(dj.kredit)
            WHEN 'Kredit' THEN SUM(dj.kredit) - SUM(dj.debit)
        END AS saldo
    FROM Detail_Jurnal dj
    JOIN Akun a          ON dj.id_akun     = a.id_akun
    JOIN Kategori_Akun ka ON a.id_kategori  = ka.id_kategori
    GROUP BY a.id_akun, ka.tipe, ka.normal_saldo
)
SELECT
    SUM(CASE WHEN tipe = 'Pendapatan' THEN saldo ELSE 0 END) AS total_pendapatan,
    SUM(CASE WHEN tipe IN ('Beban','Harga Pokok Penjualan') THEN saldo ELSE 0 END) AS total_beban,
    SUM(CASE WHEN tipe = 'Pendapatan' THEN saldo ELSE 0 END) -
    SUM(CASE WHEN tipe IN ('Beban','Harga Pokok Penjualan') THEN saldo ELSE 0 END) AS laba_bersih
FROM saldo_akun;

-- 3.5 Neraca (Balance Sheet) — posisi Aset vs Kewajiban + Modal
WITH saldo_akun AS (
    SELECT a.id_akun, a.nama_akun, ka.tipe,
        CASE ka.normal_saldo
            WHEN 'Debit'  THEN SUM(dj.debit) - SUM(dj.kredit)
            WHEN 'Kredit' THEN SUM(dj.kredit) - SUM(dj.debit)
        END AS saldo
    FROM Detail_Jurnal dj
    JOIN Akun a          ON dj.id_akun     = a.id_akun
    JOIN Kategori_Akun ka ON a.id_kategori  = ka.id_kategori
    GROUP BY a.id_akun, a.nama_akun, ka.tipe, ka.normal_saldo
)
SELECT
    nama_akun, tipe, saldo,
    CASE WHEN tipe IN ('Aset') THEN saldo ELSE 0 END AS sisi_aset,
    CASE WHEN tipe IN ('Kewajiban','Modal') THEN saldo ELSE 0 END AS sisi_pasiva
FROM saldo_akun
WHERE saldo != 0
ORDER BY tipe, nama_akun;

-- 3.6 Verifikasi: total debit harus = total kredit (double-entry check)
SELECT
    SUM(debit)  AS total_debit,
    SUM(kredit) AS total_kredit,
    SUM(debit) - SUM(kredit) AS selisih  -- harus 0
FROM Detail_Jurnal;