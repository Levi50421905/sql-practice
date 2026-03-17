# window-function

Topik: **Window Function** — `RANK`, `ROW_NUMBER`, `LAG`, `LEAD`, dan lainnya  
Database: MariaDB 10.2+ / MySQL 8.0+  
**Muhammad Alfarezzi Fallevi** · 4IA17 · NPM 50421905

---

## Apa itu Window Function?

Window Function melakukan kalkulasi pada sekumpulan baris yang berhubungan dengan baris saat ini — **tanpa menghilangkan baris** seperti `GROUP BY`.

```
fungsi() OVER (
    [PARTITION BY kolom]   ← pengelompokan (opsional)
    [ORDER BY kolom]       ← urutan dalam kelompok
    [ROWS/RANGE frame]     ← jendela baris (opsional)
)
```

| Konsep | Penjelasan |
|---|---|
| `PARTITION BY` | Seperti `GROUP BY`, tapi baris tidak di-collapse |
| `ORDER BY` | Urutan baris dalam setiap partisi |
| Frame (`ROWS BETWEEN ...`) | Mendefinisikan "jendela" baris untuk kalkulasi |

---

## Fungsi yang Dicakup

| Fungsi | Kegunaan |
|---|---|
| `ROW_NUMBER()` | Nomor urut unik per baris dalam partisi |
| `RANK()` | Ranking dengan lompatan jika ada nilai sama |
| `DENSE_RANK()` | Ranking tanpa lompatan jika ada nilai sama |
| `LAG(col, n)` | Nilai n baris sebelumnya |
| `LEAD(col, n)` | Nilai n baris sesudahnya |
| `SUM() OVER()` | Running total / kontribusi persentase |
| `AVG() OVER()` | Moving average |
| `NTILE(n)` | Membagi baris ke n kelompok (bucket) |
| `FIRST_VALUE()` | Nilai pertama dalam partisi |
| `LAST_VALUE()` | Nilai terakhir dalam partisi |

---

## Dataset

### `penjualan`
Data penjualan 6 sales di 2 divisi selama 3 bulan (Jan–Mar 2025).

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INT | PRIMARY KEY |
| nama_sales | VARCHAR(50) | Nama sales |
| divisi | VARCHAR(50) | Elektronik / Fashion |
| bulan | VARCHAR(7) | Format YYYY-MM |
| total_penjualan | INT | Nilai penjualan (Rp) |

### `nilai_mahasiswa`
Nilai 5 mahasiswa di 2 mata kuliah.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INT | PRIMARY KEY |
| nama | VARCHAR(50) | Nama mahasiswa |
| mata_kuliah | VARCHAR(50) | Nama mata kuliah |
| nilai | INT | Nilai ujian (0–100) |

---

## Ringkasan Query per Section

| Section | Fungsi | Contoh Use Case |
|---|---|---|
| 2 | `ROW_NUMBER()` | Urutan sales per divisi, ambil top-1 |
| 3 | `RANK()`, `DENSE_RANK()` | Ranking nilai, perbedaan tie-breaking |
| 4 | `LAG()`, `LEAD()` | Selisih vs bulan lalu, growth % (MoM) |
| 5 | `SUM/AVG OVER()` | % kontribusi, running total, moving average |
| 6 | `NTILE()` | Bagi mahasiswa ke kelompok nilai |
| 7 | `FIRST_VALUE()` | Tampilkan nilai tertinggi di setiap baris |

---

## Perbedaan RANK vs DENSE_RANK

```
Nilai:  92, 88, 88, 75, 65

RANK():        1,  2,  2,  4,  5   ← lompat dari 2 ke 4
DENSE_RANK():  1,  2,  2,  3,  4   ← tidak lompat
```

---

## Perbedaan vs GROUP BY

```sql
-- GROUP BY → hanya 1 baris per divisi
SELECT divisi, SUM(total_penjualan) FROM penjualan GROUP BY divisi;

-- Window Function → semua baris tetap tampil + nilai agregat
SELECT nama_sales, divisi, total_penjualan,
       SUM(total_penjualan) OVER (PARTITION BY divisi) AS total_divisi
FROM penjualan;
```

---

## Cara Pakai

```bash
mysql -u root -p < window_function.sql
```