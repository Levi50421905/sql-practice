# 💰 Studi Kasus: Sistem Keuangan

**Topik:** Studi Kasus — Double-Entry Bookkeeping & Laporan Keuangan  
**Database:** MariaDB / MySQL  
**Author:** Muhammad Alfarezzi Fallevi · 4IA17 · 50421905

---

## 🧠 Deskripsi Kasus

Sistem pencatatan keuangan perusahaan menggunakan metode **double-entry bookkeeping** — prinsip dasar akuntansi di mana setiap transaksi selalu dicatat di dua sisi: **Debit** dan **Kredit**, dengan total keduanya selalu sama.

Database ini mencakup: daftar akun (chart of accounts), pencatatan jurnal transaksi, hingga pembuatan laporan keuangan standar (laba rugi & neraca) langsung dari SQL.

---

## 📖 Konsep Double-Entry Bookkeeping

Setiap transaksi keuangan memengaruhi minimal dua akun:

```
Contoh: Terima pembayaran pelanggan Rp 8.500.000 via bank

  Debit  → Bank BCA     +8.500.000  (aset naik)
  Kredit → Pendapatan   +8.500.000  (pendapatan naik)

Aturan: Total Debit = Total Kredit SELALU
```

### Aturan Normal Saldo

| Tipe Akun | Naik dengan | Turun dengan |
|---|---|---|
| **Aset** | Debit | Kredit |
| **Kewajiban** | Kredit | Debit |
| **Modal** | Kredit | Debit |
| **Pendapatan** | Kredit | Debit |
| **Beban** | Debit | Kredit |

---

## 🗂️ Struktur Database

```
keuangan_db
│
├── Kategori_Akun   → tipe akun (Aset/Kewajiban/Modal/Pendapatan/Beban)
│                     + normal saldo (Debit/Kredit)
├── Akun            → chart of accounts / daftar akun (kode + nama)
│
├── Jurnal          → header transaksi (tanggal, deskripsi, referensi)
└── Detail_Jurnal   → entri debit/kredit per akun per transaksi
```

**Desain ini mengikuti pola Double-Entry:** satu transaksi (Jurnal) → banyak baris (Detail_Jurnal), masing-masing punya debit atau kredit.

---

## 📋 Daftar Akun (Chart of Accounts)

| Kode | Nama | Tipe | Normal Saldo |
|---|---|---|---|
| 1-001 | Kas | Aset | Debit |
| 1-002 | Bank BCA | Aset | Debit |
| 1-003 | Piutang Usaha | Aset | Debit |
| 1-004 | Persediaan Barang | Aset | Debit |
| 2-001 | Peralatan & Mesin | Aset Tetap | Debit |
| 3-001 | Hutang Usaha | Kewajiban | Kredit |
| 4-001 | Modal Pemilik | Modal | Kredit |
| 5-001 | Pendapatan Penjualan | Pendapatan | Kredit |
| 5-002 | Pendapatan Jasa | Pendapatan | Kredit |
| 6-001 | Harga Pokok Penjualan | Beban | Debit |
| 6-002 | Beban Gaji | Beban | Debit |
| 6-003 | Beban Sewa Gedung | Beban | Debit |

---

## 💻 Laporan Keuangan dari SQL

### Neraca Saldo (Trial Balance)
Tampilkan saldo akhir setiap akun — verifikasi bahwa total debit = total kredit:

```sql
SELECT a.nama_akun, ka.tipe,
    SUM(dj.debit)  AS total_debit,
    SUM(dj.kredit) AS total_kredit,
    CASE ka.normal_saldo
        WHEN 'Debit'  THEN SUM(dj.debit) - SUM(dj.kredit)
        WHEN 'Kredit' THEN SUM(dj.kredit) - SUM(dj.debit)
    END AS saldo
FROM Detail_Jurnal dj
JOIN Akun a          ON dj.id_akun    = a.id_akun
JOIN Kategori_Akun ka ON a.id_kategori = ka.id_kategori
GROUP BY a.id_akun, a.nama_akun, ka.tipe, ka.normal_saldo;
```

### Buku Besar (dengan Window Function)
Tampilkan saldo berjalan per akun:

```sql
SELECT a.nama_akun, j.tgl_jurnal, dj.debit, dj.kredit,
    SUM(dj.debit - dj.kredit) OVER (
        PARTITION BY a.id_akun
        ORDER BY j.tgl_jurnal
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS saldo_berjalan
FROM Detail_Jurnal dj
JOIN Akun a   ON dj.id_akun  = a.id_akun
JOIN Jurnal j ON dj.id_jurnal = j.id_jurnal;
```

### Laba Rugi (Income Statement)
Hitung laba bersih bulan ini:

```sql
-- Dari CTE saldo_akun:
SELECT
    SUM(CASE WHEN tipe = 'Pendapatan' THEN saldo ELSE 0 END)                        AS total_pendapatan,
    SUM(CASE WHEN tipe IN ('Beban','Harga Pokok Penjualan') THEN saldo ELSE 0 END)  AS total_beban,
    [total_pendapatan] - [total_beban]                                               AS laba_bersih
FROM saldo_akun;
```

### Verifikasi Double-Entry
Pastikan pembukuan balance — total debit = total kredit:

```sql
SELECT
    SUM(debit)         AS total_debit,
    SUM(kredit)        AS total_kredit,
    SUM(debit) - SUM(kredit) AS selisih  -- harus 0!
FROM Detail_Jurnal;
```

---

## 🆕 Teknik SQL yang Dipelajari

| Teknik | Dipakai Untuk |
|---|---|
| **CASE WHEN dalam agregasi** | Hitung total hanya untuk tipe akun tertentu |
| **CTE berantai** | Hitung saldo akun → pakai lagi untuk laporan LR/Neraca |
| **Window Function SUM OVER** | Buku besar — saldo berjalan per akun |
| **Multiple JOIN** | Hubungkan Detail_Jurnal → Akun → Kategori_Akun → Jurnal |
| **ENUM** | Tipe akun dan normal saldo (Debit/Kredit) |

---

## 📊 Transaksi Bulan Juni 2025

| Jurnal | Transaksi |
|---|---|
| JRN001 | Setoran modal awal Rp 50 juta |
| JRN002 | Beli peralatan kantor Rp 15 juta (tunai) |
| JRN003 | Beli persediaan Rp 20 juta (kredit/hutang) |
| JRN004 | Penjualan tunai Rp 8,5 juta + HPP |
| JRN005 | Penjualan kredit Rp 12 juta + HPP |
| JRN006 | Pendapatan jasa konsultasi Rp 5 juta |
| JRN007 | Bayar sewa Rp 3 juta |
| JRN008 | Gaji karyawan Rp 8 juta |
| JRN009 | Utilitas Rp 750rb |
| JRN010 | Terima pelunasan piutang |
| JRN011 | Bayar hutang ke supplier |
| JRN012 | Biaya pemasaran Rp 1,5 juta |
| JRN013 | Penyusutan peralatan Rp 250rb |
| JRN014 | Penjualan akhir bulan |

---

## 🗂️ Isi File `keuangan.sql`

| Section | Isi |
|---|---|
| 1 | DDL — 4 tabel: Kategori_Akun, Akun, Jurnal, Detail_Jurnal |
| 2 | INSERT — chart of accounts + 14 jurnal transaksi bulan Juni |
| 3 | Buku Besar (Window Function), Neraca Saldo, Laba Rugi, Neraca, Verifikasi |

---

## 🚀 Cara Pakai

```bash
mysql -u root -p < keuangan.sql
```