# poliklinik

Materi: **Insinyur Data Madya – Sesi 02** · Studi Kasus Poliklinik  
Rabu, 11 Juni 2025  
**Muhammad Alfarezzi Fallevi** · 4IA17 · NPM 50421905

---

## Deskripsi

Database `poliklinik` mensimulasikan sistem informasi klinik, mencakup data pasien, dokter, klinik, layanan medis, asuransi, dan kunjungan. Studi kasus ini mencakup 4 instruksi kerja: ERD, DDL, DML + DQL analitik, dan integrasi data dari file CSV.

---

## Instruksi Kerja

| IK | Topik | File |
|---|---|---|
| IK-1 | ERD — desain relasi antar entitas | `ERD.pdf` |
| IK-2 | DDL — membuat semua tabel | `poliklinik.sql` Section 2 |
| IK-3 | DML + SELECT analitik | `poliklinik.sql` Section 3 & 5 |
| IK-4 | Integrasi CSV via `LOAD DATA INFILE` | `poliklinik.sql` Section 4, `dataKlinik.csv` |

---

## Struktur Database

```
poliklinik
├── Pasien          → data pasien
├── Dokter          → data dokter
├── Klinik          → daftar klinik / poli
├── Layanan         → jenis layanan medis
├── Asuransi        → jenis asuransi
└── Kunjungan       → transaksi kunjungan (FK ke semua tabel di atas)
```

### ERD Relasi

```
Pasien  (1) ──melakukan──  (M)
Dokter  (1) ──────────────────  Kunjungan  ──── (1) Klinik
Layanan (1) ──────────────────       │
Asuransi(1) ──────────────────       │
                                     └──── (M) per baris transaksi
```

| Relasi | Tipe | Keterangan |
|---|---|---|
| Pasien → Kunjungan | One-to-Many | 1 pasien bisa banyak kunjungan |
| Dokter → Kunjungan | One-to-Many | 1 dokter bisa tangani banyak kunjungan |
| Klinik → Kunjungan | One-to-Many | 1 klinik untuk banyak kunjungan |
| Layanan → Kunjungan | One-to-Many | 1 jenis layanan untuk banyak kunjungan |
| Asuransi → Kunjungan | One-to-Many | 1 asuransi dipakai banyak kunjungan |

---

## Skema Tabel

### `Pasien`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_pasien | VARCHAR(10) | PRIMARY KEY |
| nama_pasien | VARCHAR(100) | Nama lengkap pasien |
| tgl_lahir | DATE | Tanggal lahir |
| alamat | TEXT | Alamat |
| no_hp | VARCHAR(15) | Nomor HP |

### `Dokter`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_dokter | VARCHAR(10) | PRIMARY KEY |
| nama_dokter | VARCHAR(100) | Nama dokter |
| alamat | TEXT | Alamat |
| no_hp | VARCHAR(15) | Nomor HP |

### `Klinik`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_klinik | VARCHAR(10) | PRIMARY KEY |
| nama_klinik | VARCHAR(100) | Nama klinik / poli |

### `Layanan`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_layanan | VARCHAR(10) | PRIMARY KEY |
| jenis_layanan | VARCHAR(100) | Jenis layanan medis |

### `Asuransi`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_asuransi | VARCHAR(10) | PRIMARY KEY |
| nama_asuransi | VARCHAR(100) | Nama asuransi |

### `Kunjungan`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_kunjungan | VARCHAR(10) | PRIMARY KEY |
| tanggal_kunjungan | DATE | Tanggal kunjungan |
| total_bayar | INT | Total biaya kunjungan |
| id_pasien | VARCHAR(10) | FK → Pasien |
| id_dokter | VARCHAR(10) | FK → Dokter |
| id_klinik | VARCHAR(10) | FK → Klinik |
| id_layanan | VARCHAR(10) | FK → Layanan |
| id_asuransi | VARCHAR(10) | FK → Asuransi |

---

## Queries Utama (Instruksi Kerja 3)

```sql
-- Soal 1: Hitung jumlah pasien pengguna ASKES
SELECT COUNT(*) AS jumlah_pasien_askes
FROM Kunjungan k
JOIN Asuransi a ON k.id_asuransi = a.id_asuransi
WHERE a.nama_asuransi = 'ASKES';
-- Hasil: 3

-- Soal 2: Dokter di Klinik Penyakit Dalam
SELECT d.nama_dokter
FROM Dokter d
JOIN Kunjungan k  ON d.id_dokter = k.id_dokter
JOIN Klinik    kl ON k.id_klinik = kl.id_klinik
WHERE kl.nama_klinik = 'Klinik Penyakit Dalam'
GROUP BY d.nama_dokter;
-- Hasil: dr. Satrio, dr. Yudi

-- Soal 3: Pasien yang diperiksa dr. Nila
SELECT p.nama_pasien
FROM Pasien p
JOIN Kunjungan k ON p.id_pasien = k.id_pasien
JOIN Dokter    d ON k.id_dokter = d.id_dokter
WHERE d.nama_dokter = 'dr. Nila';
-- Hasil: Rudianto, Lestari
```

---

## Integrasi CSV (Instruksi Kerja 4)

File `dataKlinik.csv` berisi data klinik tambahan (KL010–KL012) dengan separator `;`:

```
id_klinik;nama_klinik
KL010;Jantung
KL011;Paru
KL012;Saraf
```

Perintah `LOAD DATA LOCAL INFILE` untuk menggabungkan ke tabel `Klinik`:

```sql
LOAD DATA LOCAL INFILE '/path/to/dataKlinik.csv'
    INTO TABLE Klinik
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (id_klinik, nama_klinik);
```

> Data KL010–KL012 sudah di-INSERT langsung di `poliklinik.sql` Section 3 agar file bisa dijalankan tanpa file eksternal.

---

## File

| File | Keterangan |
|---|---|
| `poliklinik.sql` | Schema + data + semua queries |
| `dataKlinik.csv` | Data klinik tambahan untuk LOAD DATA INFILE |
| `README.md` | Dokumentasi folder ini |

---

## Cara Pakai

```bash
# Import lengkap ke MariaDB / MySQL
mysql -u root -p < poliklinik.sql

# Atau jalankan manual di client
mysql -u root -p
source /path/to/poliklinik.sql
```