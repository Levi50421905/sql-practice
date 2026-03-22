# 🎓 Studi Kasus: Sistem E-Learning

**Topik:** Studi Kasus — Database Platform Kursus Online  
**Database:** MariaDB / MySQL  
**Author:** Muhammad Alfarezzi Fallevi · 4IA17 · 50421905

---

## 🧠 Deskripsi Kasus

Sebuah platform e-learning membutuhkan database untuk mengelola:
- Instruktur dan kursus yang mereka buat
- Mahasiswa yang mendaftar kursus
- Progress belajar per materi
- Hasil kuis dan kelulusan
- Penerbitan sertifikat

Studi kasus ini melatih JOIN multi-tabel yang dalam, penggunaan ENUM, kolom GENERATED, GROUP_CONCAT, CTE, dan Window Function dalam satu sistem yang nyata.

---

## 🗂️ Struktur Database

```
elearning_db
│
├── Instruktur        → data instruktur & rating
│     ↓ (1:M)
├── Kursus            → kursus yang dibuat instruktur
│     ↓ (1:M)
├── Materi            → materi/modul per kursus (ada urutan & durasi)
│
├── Mahasiswa         → data mahasiswa
│     ↓ (M:M via Enrollment)
├── Enrollment        → pendaftaran mahasiswa ke kursus
│     ├── → Progress  → progress per materi (selesai/belum)
│     └── → Nilai_Kuis → hasil kuis per mahasiswa
│
├── Kuis              → kuis yang ada di kursus
└── Sertifikat        → sertifikat untuk enrollment yang selesai
```

---

## 📋 Skema Tabel

### `Instruktur`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_instruktur | VARCHAR(10) | PRIMARY KEY |
| nama | VARCHAR(100) | Nama instruktur |
| email | VARCHAR(100) | Email |
| spesialisasi | VARCHAR(100) | Bidang keahlian |
| rating | DECIMAL(3,2) | Rating rata-rata (0.00–5.00) |

### `Kursus`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_kursus | VARCHAR(10) | PRIMARY KEY |
| judul | VARCHAR(200) | Judul kursus |
| kategori | VARCHAR(50) | Database, Web Dev, dll |
| level | ENUM | `Pemula`, `Menengah`, `Lanjut` |
| harga | INT | Harga kursus (Rp) |
| durasi_jam | INT | Total durasi dalam jam |
| id_instruktur | VARCHAR(10) | FK → Instruktur |

### `Enrollment`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_enrollment | VARCHAR(10) | PRIMARY KEY |
| id_mahasiswa | VARCHAR(10) | FK → Mahasiswa |
| id_kursus | VARCHAR(10) | FK → Kursus |
| tgl_enroll | DATE | Tanggal daftar |
| tgl_selesai | DATE NULL | Tanggal selesai (NULL jika masih aktif) |
| status | ENUM | `Aktif`, `Selesai`, `Berhenti` |

### `Nilai_Kuis`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id_nilai | INT | PRIMARY KEY |
| id_enrollment | VARCHAR(10) | FK → Enrollment |
| id_kuis | VARCHAR(10) | FK → Kuis |
| nilai | INT | Nilai kuis (0–100) |
| tgl_kuis | DATE | Tanggal mengerjakan |
| **lulus** | **BOOLEAN GENERATED** | **Otomatis: nilai >= 70** |

---

## 🆕 Fitur SQL Baru yang Dipelajari

### ENUM
Tipe data untuk nilai yang sudah ditentukan pilihan-nya:
```sql
level ENUM('Pemula', 'Menengah', 'Lanjut')
status ENUM('Aktif', 'Selesai', 'Berhenti') DEFAULT 'Aktif'
-- Lebih aman dari VARCHAR — input di luar pilihan ditolak
```

### Kolom GENERATED (Computed Column)
Kolom yang nilainya **dihitung otomatis** dari kolom lain — tidak perlu diisi manual:
```sql
lulus BOOLEAN GENERATED ALWAYS AS (nilai >= 70) STORED
-- Jika nilai >= 70 → lulus = TRUE (otomatis)
-- Jika nilai < 70  → lulus = FALSE (otomatis)
-- STORED: disimpan di disk; VIRTUAL: dihitung saat query
```

### GROUP_CONCAT
Gabungkan banyak nilai dari banyak baris menjadi satu string:
```sql
GROUP_CONCAT(k.judul SEPARATOR ' | ')
-- Hasil: "SQL dari Nol | Web Development Full Stack"
```

---

## 💻 Query Analitik

### Progress Belajar (%) per Mahasiswa
```sql
SELECT m.nama, k.judul AS kursus,
       COUNT(p.id_progress)  AS materi_ditempuh,
       SUM(p.selesai)        AS materi_selesai,
       ROUND(SUM(p.selesai) / COUNT(p.id_progress) * 100, 1) AS pct_progress
FROM Enrollment e
JOIN Mahasiswa m ON e.id_mahasiswa  = m.id_mahasiswa
JOIN Kursus k    ON e.id_kursus     = k.id_kursus
JOIN Progress p  ON e.id_enrollment = p.id_enrollment
GROUP BY e.id_enrollment, m.nama, k.judul
ORDER BY pct_progress DESC;
```

### Mahasiswa Multi-Kursus (GROUP_CONCAT + HAVING)
```sql
SELECT m.nama,
       COUNT(e.id_enrollment) AS jumlah_kursus,
       GROUP_CONCAT(k.judul SEPARATOR ' | ') AS daftar_kursus
FROM Mahasiswa m
JOIN Enrollment e ON m.id_mahasiswa = e.id_mahasiswa
JOIN Kursus k     ON e.id_kursus    = k.id_kursus
GROUP BY m.id_mahasiswa, m.nama
HAVING COUNT(e.id_enrollment) > 1;
```

### Ranking Mahasiswa by Nilai (CTE + RANK)
```sql
WITH avg_nilai AS (
    SELECT m.nama, AVG(nk.nilai) AS rata_nilai
    FROM Nilai_Kuis nk
    JOIN Enrollment e ON nk.id_enrollment = e.id_enrollment
    JOIN Mahasiswa m  ON e.id_mahasiswa   = m.id_mahasiswa
    GROUP BY m.id_mahasiswa, m.nama
)
SELECT nama, ROUND(rata_nilai, 2),
       RANK() OVER (ORDER BY rata_nilai DESC) AS peringkat
FROM avg_nilai;
```

---

## 🗂️ Isi File `elearning.sql`

| Section | Isi |
|---|---|
| 1 | DDL — 9 tabel dengan ENUM, GENERATED column, semua FK |
| 2 | INSERT — data instruktur, kursus, materi, mahasiswa, enrollment, progress, kuis, nilai, sertifikat |
| 3 | 8 query analitik — progress, sertifikat, rekap nilai, pendapatan instruktur, ranking |

---

## 🚀 Cara Pakai

```bash
mysql -u root -p < elearning.sql
```