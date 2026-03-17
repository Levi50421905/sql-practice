# membuat-database-engineer

Materi: **Insinyur Data Madya – Sesi 02** · Membuat Database  
Tugas Harian, Selasa 10 Juni 2025  
**Muhammad Alfarezzi Fallevi** · 4IA17 · NPM 50421905

---

## Deskripsi

Database `engineerl` mensimulasikan sistem manajemen proyek engineering sederhana. Terdapat 4 tabel yang saling berelasi, mencakup data insinyur, proyek, tugas, dan keterlibatan insinyur di setiap proyek.

---

## Struktur Database

```
engineerl
├── engineers          → data insinyur
├── project            → data proyek
├── task               → tugas per proyek (FK → project)
└── engineer_projects  → junction table insinyur ↔ proyek (FK → engineers, project)
```

### ERD Relasi

```
engineers (1) ──── (M) engineer_projects (M) ──── (1) project
                                                        │
                                                       (1)
                                                        │
                                                       (M)
                                                       task
```

| Relasi | Tipe | Keterangan |
|---|---|---|
| engineers ↔ project | Many-to-Many | via tabel `engineer_projects` |
| project ↔ task | One-to-Many | 1 project punya banyak task |

---

## Skema Tabel

### `engineers`
| Kolom | Tipe | Keterangan |
|---|---|---|
| engineer_id | VARCHAR(10) | PRIMARY KEY |
| name | VARCHAR(100) | Nama insinyur |
| email | VARCHAR(100) | Email |
| join_date | DATE | Tanggal bergabung |

### `project`
| Kolom | Tipe | Keterangan |
|---|---|---|
| project_id | VARCHAR(3) | PRIMARY KEY |
| name | VARCHAR(50) | Nama proyek *(ditambah via ALTER TABLE)* |
| start_date | DATE | Tanggal mulai |
| end_date | DATE | Tanggal berakhir |

### `task`
| Kolom | Tipe | Keterangan |
|---|---|---|
| task_id | VARCHAR(3) | PRIMARY KEY |
| description | VARCHAR(100) | Deskripsi tugas |
| status | VARCHAR(50) | Pending / In Progress / Done |
| due_date | DATE | Jatuh tempo |
| project_id | VARCHAR(3) | FOREIGN KEY → project |

### `engineer_projects`
| Kolom | Tipe | Keterangan |
|---|---|---|
| engineer_id | VARCHAR(3) | FOREIGN KEY → engineers (PK bersama) |
| project_id | VARCHAR(3) | FOREIGN KEY → project (PK bersama) |
| role | VARCHAR(20) | Peran dalam proyek |

---

## Isi File

### `engineerl.sql`

| Section | Isi |
|---|---|
| **Section 1** | Setup database (`CREATE DATABASE`, `USE`) |
| **Section 2** | DDL — `CREATE TABLE` + `ALTER TABLE` |
| **Section 3** | DML — `INSERT INTO` semua tabel |
| **Section 4** | DQL — `SELECT` biasa, JOIN, GROUP BY, WHERE |
| **Section 5** | `DESCRIBE` + `SHOW TABLES` |

**Query yang dicakup di Section 4:**
- SELECT semua data per tabel
- JOIN 3 tabel: keterlibatan insinyur dalam proyek
- JOIN task dengan nama proyek
- COUNT task per proyek (`GROUP BY`)
- COUNT insinyur per proyek (`GROUP BY`)
- Filter insinyur by `join_date`
- Filter task yang belum selesai (`WHERE status != 'Done'`)

---

## Cara Pakai

```bash
# Import ke MariaDB / MySQL
mysql -u root -p < engineerl.sql

# Atau jalankan manual di client
mysql -u root -p
source /path/to/engineerl.sql
```

---

## Catatan

- `project` pakai nama tabel tunggal (sesuai implementasi asli di tugas)
- Kolom `name` pada tabel `project` sengaja ditambahkan via `ALTER TABLE` untuk menunjukkan penggunaan DDL alternatif
- Constraint `ON UPDATE CASCADE` dan `ON DELETE` ditambahkan sebagai best practice (tidak ada di tugas asli)