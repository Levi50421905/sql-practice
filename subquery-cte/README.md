# subquery-cte

Topik: **Subquery & CTE** — Nested Query, Derived Table, WITH, Recursive CTE  
Database: MariaDB 10.2+ / MySQL 8.0+  
**Muhammad Alfarezzi Fallevi** · 4IA17 · NPM 50421905

---

## Subquery vs CTE

| | Subquery | CTE (`WITH`) |
|---|---|---|
| Posisi | Di dalam `WHERE`, `FROM`, `SELECT` | Di atas query utama |
| Diberi nama | Tidak (anonim) | Ya |
| Bisa dipakai ulang | Tidak | Ya (dalam 1 query) |
| Bisa rekursif | Tidak | Ya (`WITH RECURSIVE`) |
| Keterbacaan | Sulit jika nested dalam | Lebih bersih |

---

## Dataset

Database `ecommerce_db`:

```
ecommerce_db
├── Pelanggan           → data pelanggan
├── Produk              → data produk + kategori + harga
├── Transaksi           → header transaksi per pelanggan
├── Detail_Transaksi    → item per transaksi (FK → Transaksi, Produk)
└── Karyawan            → hierarki organisasi (self-referencing FK)
```

---

## Ringkasan Query per Section

| Section | Topik | Contoh Use Case |
|---|---|---|
| 2 | Subquery di `WHERE` | Produk di atas harga rata-rata, `IN`, `NOT IN`, `EXISTS` |
| 3 | Subquery di `FROM` (Derived Table) | Rata-rata transaksi, top-3 produk per kategori |
| 4 | Subquery di `SELECT` (Scalar) | Total bayar per transaksi, frekuensi beli per produk |
| 5 | CTE non-recursive | Total belanja, pelanggan VIP, % kontribusi revenue |
| 6 | Recursive CTE | Struktur organisasi, hitung jumlah bawahan |

---

## Pola Subquery

### Di WHERE
```sql
-- Scalar: bandingkan dengan 1 nilai
WHERE harga > (SELECT AVG(harga) FROM Produk)

-- Multi-row: cek keanggotaan
WHERE id IN (SELECT id FROM tabel WHERE kondisi)

-- Existential: cek keberadaan baris
WHERE EXISTS (SELECT 1 FROM tabel WHERE kondisi)
```

### Di FROM (Derived Table)
```sql
SELECT * FROM (
    SELECT kolom, agregat FROM tabel GROUP BY kolom
) AS alias
WHERE alias.agregat > nilai
```

### Di SELECT (Scalar)
```sql
SELECT nama,
       (SELECT COUNT(*) FROM detail WHERE detail.id = utama.id) AS jumlah
FROM utama
```

---

## Pola CTE

### CTE Tunggal
```sql
WITH nama_cte AS (
    SELECT ... FROM ... WHERE ...
)
SELECT * FROM nama_cte;
```

### CTE Berantai (Multiple CTE)
```sql
WITH
cte_pertama AS (SELECT ...),
cte_kedua   AS (SELECT ... FROM cte_pertama WHERE ...)
SELECT * FROM cte_kedua;
```

### Recursive CTE
```sql
WITH RECURSIVE nama AS (
    -- Anchor member (titik awal)
    SELECT ... WHERE kondisi_awal

    UNION ALL

    -- Recursive member (sambung ke bawah)
    SELECT ... FROM tabel JOIN nama ON kondisi_rekursi
)
SELECT * FROM nama;
```

---

## Kapan Pakai Apa?

| Situasi | Pilihan |
|---|---|
| Filter dengan hasil query lain | Subquery di `WHERE` |
| Agregasi yang perlu diagregasi lagi | Subquery di `FROM` |
| Nilai kalkulasi per baris | Subquery di `SELECT` |
| Query kompleks, dipakai > 1x | CTE |
| Data hierarki (pohon, BOM, org chart) | Recursive CTE |
| Performa kritis, data besar | Window Function lebih efisien |

---

## Cara Pakai

```bash
mysql -u root -p < subquery_cte.sql
```