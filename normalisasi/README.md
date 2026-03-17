# normalisasi

Topik: **Normalisasi Database** — 1NF, 2NF, 3NF  
Database: MariaDB / MySQL  
**Muhammad Alfarezzi Fallevi** · 4IA17 · NPM 50421905

---

## Apa itu Normalisasi?

Normalisasi adalah proses mendesain struktur tabel database agar:
- **Tidak ada redundansi** (data tidak tersimpan duplikat)
- **Tidak ada anomali** INSERT, UPDATE, DELETE

---

## Studi Kasus

Data pemesanan tiket **seminar/workshop** yang awalnya disimpan dalam satu tabel tidak ternormalisasi, lalu bertahap dinormalisasi sampai 3NF.

---

## Perjalanan Normalisasi

### 0NF → Belum Ternormalisasi

```
id_pesan | nama_peserta | nama_seminar              | harga
---------|--------------|---------------------------|------------------
PO001    | Levi         | SQL Dasar, Python Lanjut  | 150000, 200000
```

❌ Masalah: satu kolom berisi banyak nilai (multi-value)

---

### 1NF — First Normal Form

**Aturan:** setiap kolom hanya berisi 1 nilai (atomic), ada primary key.

```
(id_pemesanan, id_seminar) ← composite PK
```

```
PO001 | Levi | SQL Dasar     | 2025-06-01 | 150000 | Dr. Andi
PO001 | Levi | Python Lanjut | 2025-06-15 | 200000 | Prof. Budi
```

✅ Sudah atomic  
❌ Masalah baru: data Levi (nama, email, kota) **berulang** di setiap baris → **Partial Dependency**

---

### 2NF — Second Normal Form

**Aturan:** hilangkan **Partial Dependency** — semua kolom non-key harus bergantung pada **seluruh** PK.

Pemisahan ke 3 tabel:

| Tabel | Bergantung pada |
|---|---|
| `Peserta` | `id_peserta` saja |
| `Seminar_2NF` | `id_seminar` saja |
| `Pemesanan_2NF` | `(id_pemesanan, id_seminar)` — keduanya |

✅ Tidak ada partial dependency  
❌ Masalah baru: `nama_pembicara` ada di tabel Seminar, tapi pembicara punya atribut lain → **Transitive Dependency**

---

### 3NF — Third Normal Form

**Aturan:** hilangkan **Transitive Dependency** — kolom non-key tidak boleh bergantung pada kolom non-key lain.

Pemisahan ke 4 tabel final:

```
normalisasi_db (3NF)
├── Peserta       → id_peserta, nama, email, telepon, kota_asal
├── Pembicara     → id_pembicara, nama_pembicara, afiliasi, email
├── Seminar       → id_seminar, nama_seminar, tgl_seminar, harga, id_pembicara (FK)
└── Pemesanan     → id_pemesanan, id_peserta (FK), id_seminar (FK), tgl_pesan
```

✅ Tidak ada redundansi  
✅ Tidak ada anomali update/delete

---

## Rangkuman Aturan Normal Form

| Form | Aturan Tambahan | Masalah yang Dihilangkan |
|---|---|---|
| **1NF** | Nilai atomic, ada PK | Multi-value, repeating groups |
| **2NF** | Sudah 1NF + tidak ada Partial Dependency | Redundansi akibat composite PK |
| **3NF** | Sudah 2NF + tidak ada Transitive Dependency | Kolom non-key bergantung pada non-key lain |

---

## Anomali yang Dicegah

| Anomali | Contoh jika tidak dinormalisasi |
|---|---|
| **Insert** | Tidak bisa simpan data pembicara tanpa ada seminar dulu |
| **Update** | Ganti nama pembicara → harus update semua baris seminar |
| **Delete** | Hapus satu-satunya peserta seminar → data seminar ikut hilang |

---

## Cara Pakai

```bash
mysql -u root -p < normalisasi.sql
```