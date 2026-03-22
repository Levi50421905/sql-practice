# 🔍 Full-Text Search

**Topik:** Full-Text Search — `MATCH AGAINST`, FULLTEXT Index, Boolean Mode  
**Database:** MariaDB / MySQL (InnoDB, MySQL 5.6+ / MariaDB 10.0+)  
**Author:** Muhammad Alfarezzi Fallevi · 4IA17 · 50421905

---

## 🧠 Mengapa Tidak Cukup Pakai LIKE?

Bayangkan kamu punya tabel artikel dengan jutaan baris. Ketika mencari kata "database":

```sql
-- LIKE: MySQL harus scan SEMUA baris satu per satu → lambat!
WHERE konten LIKE '%database%'

-- MATCH AGAINST: pakai FULLTEXT index → cepat + ada skor relevansi
WHERE MATCH(konten) AGAINST('database')
```

Kelemahan `LIKE '%kata%'`:
- Tidak bisa pakai index (full table scan)
- Tidak ada skor relevansi — semua hasil dianggap sama
- Tidak mendukung operator pencarian seperti "wajib ada" atau "tidak boleh ada"

---

## 📖 Konsep Full-Text Search

### FULLTEXT Index
Sebelum bisa pakai `MATCH AGAINST`, kolom harus punya FULLTEXT index:

```sql
-- Saat CREATE TABLE
CREATE TABLE artikel (
    judul  VARCHAR(255),
    konten TEXT,
    FULLTEXT INDEX idx_fts (judul, konten)  -- bisa multi-kolom
) ENGINE=InnoDB;

-- Pada tabel yang sudah ada
ALTER TABLE artikel ADD FULLTEXT INDEX idx_fts (judul, konten);
```

### Skor Relevansi
`MATCH AGAINST` menghasilkan **skor numerik** — semakin tinggi, semakin relevan:

```sql
SELECT judul,
       MATCH(judul, konten) AGAINST('SQL database') AS skor
FROM artikel
ORDER BY skor DESC;  -- urutkan dari paling relevan
```

---

## 📝 Tiga Mode Pencarian

### 1. Natural Language Mode (Default)
Mencari secara alami — MySQL menghitung relevansi berdasarkan frekuensi kata.

```sql
WHERE MATCH(judul, konten) AGAINST('SQL database')
-- Tanpa IN ... MODE → otomatis Natural Language
-- Hasilkan skor relevansi, baris dengan skor 0 otomatis terfilter
```

### 2. Boolean Mode
Pencarian dengan operator — memberi kontrol penuh atas hasil.

```sql
WHERE MATCH(judul, konten) AGAINST('+SQL -Python' IN BOOLEAN MODE)
```

| Operator | Fungsi | Contoh |
|---|---|---|
| `+kata` | **Wajib** ada | `+SQL` |
| `-kata` | **Tidak boleh** ada | `-Python` |
| `kata*` | Prefix/wildcard | `data*` → database, dataset, dataframe |
| `"frasa"` | Frasa **exact** | `"stored procedure"` |
| `>kata` | Naikkan skor relevansi | `>optimasi` |
| `<kata` | Turunkan skor relevansi | `<pemula` |
| `~kata` | Kurangi skor jika ada | `~tutorial` |

### 3. Query Expansion
Dua tahap: cari kata kunci → perluas dengan kata dari hasil awal.

```sql
WHERE MATCH(judul, konten) AGAINST('SQL' WITH QUERY EXPANSION)
-- Berguna untuk temukan topik yang berkaitan meski tidak eksplisit disebut
```

---

## 💻 Perbandingan Nyata

```sql
-- LIKE: semua hasil sama, tidak ada ranking
SELECT judul FROM artikel WHERE konten LIKE '%SQL%';

-- MATCH AGAINST: ada skor, bisa diurutkan by relevansi
SELECT judul,
       MATCH(judul, konten) AGAINST('SQL') AS skor
FROM artikel
WHERE MATCH(judul, konten) AGAINST('SQL')
ORDER BY skor DESC;
```

```sql
-- Boolean: cari artikel SQL tapi bukan yang membahas Python
WHERE MATCH(judul, konten) AGAINST('+SQL -Python' IN BOOLEAN MODE)

-- Boolean: cari frasa exact "stored procedure"
WHERE MATCH(judul, konten) AGAINST('"stored procedure"' IN BOOLEAN MODE)

-- Boolean: prefix search — semua kata berawalan "data"
WHERE MATCH(judul, konten) AGAINST('data*' IN BOOLEAN MODE)
-- → menemukan: database, dataset, dataframe, datatype, dll
```

---

## ⚠️ Hal Penting yang Perlu Diketahui

### Minimum Panjang Kata
MySQL mengabaikan kata yang terlalu pendek:
- InnoDB default: **3 karakter** (`innodb_ft_min_token_size = 3`)
- MyISAM default: **4 karakter** (`ft_min_word_len = 4`)

Artinya kata "SQL" (3 huruf) mungkin diabaikan tergantung konfigurasi server!

```sql
-- Cek konfigurasi
SHOW VARIABLES LIKE 'innodb_ft_min_token_size';
SHOW VARIABLES LIKE 'ft_min_word_len';
```

### Stop Words
MySQL punya daftar kata umum yang **diabaikan** (stop words): "the", "in", "a", "and", dll. Dalam Bahasa Indonesia, stop words ini mungkin tidak relevan — perlu konfigurasi tambahan untuk bahasa lokal.

### Kapan Pakai LIKE vs FTS?

| Kondisi | Gunakan |
|---|---|
| Kolom VARCHAR pendek, cari pola kode/nomor | `LIKE` |
| Kolom TEXT panjang, cari kata, butuh relevansi | `MATCH AGAINST` |
| Butuh operator boolean (wajib/tidak boleh) | `MATCH AGAINST IN BOOLEAN MODE` |
| Data kecil (< 1000 baris) | `LIKE` sudah cukup |
| Data besar (> 10.000 baris) | `MATCH AGAINST` jauh lebih cepat |

---

## 🗂️ Dataset dalam File

**Database:** `fts_demo`

- **`artikel`** — 10 artikel blog (topik: Database, Pemrograman, DevOps)  
  Kolom FTS: `judul`, `konten`

- **`produk`** — 6 produk dengan deskripsi panjang  
  Kolom FTS: `nama`, `deskripsi`

---

## 🗂️ Isi File `full_text_search.sql`

| Section | Isi |
|---|---|
| 1 | Setup + FULLTEXT index saat CREATE TABLE |
| 2 | Natural Language Mode + tampilkan skor relevansi |
| 3 | Boolean Mode — semua operator (+, -, *, "", >, <) |
| 4 | Query Expansion |
| 5 | Perbandingan langsung LIKE vs MATCH AGAINST |
| 6 | Manajemen index: tambah/hapus FULLTEXT, SHOW INDEX, cek variabel |

---

## 🚀 Cara Pakai

```bash
mysql -u root -p < full_text_search.sql
```