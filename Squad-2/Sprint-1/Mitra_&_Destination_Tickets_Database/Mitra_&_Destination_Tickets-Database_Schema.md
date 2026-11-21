# Skema Database Mitra & Tiket Destinasi

Dokumen ini menjelaskan struktur tabel `partners` dan `destination_tickets`, fungsi atribut, relasi antartabel, serta kode migrasinya.

## Tabel `partners`

| Atribut | Tipe data | Nilai / constraint | Key | Keterangan |
|---|---|---|---|---|
| `id` | UUID | `gen_random_uuid()` | Primary key | ID unik setiap mitra. |
| `user_id` | UUID | `NOT NULL`, `UNIQUE`, referensi `users(id)` | Foreign key | Akun pengguna pemilik mitra. Satu akun maksimal memiliki satu profil mitra. |
| `business_name` | VARCHAR(200) | `NOT NULL` | — | Nama mitra atau organisasi. |
| `partner_type` | ENUM | `attraction`, `tour_agent`, `accommodation`, `transport`; `NOT NULL` | — | Kategori mitra. |
| `business_type` | ENUM | `desa wisata/pokdarwis`, `bumdes`, `pt`, `cv`, `koperasi`, `perorangan`, `yayasan`, `kelompok masyarakat`, `instansi pemerintah`; `NOT NULL` | — | Bentuk usaha atau organisasi mitra. |
| `person_in_charge` | VARCHAR(100) | `NOT NULL` | — | Nama penanggung jawab. |
| `business_phone_number` | VARCHAR(32) | `NOT NULL` | — | Nomor telepon mitra. |
| `business_address` | TEXT | `NOT NULL` | — | Alamat mitra. |
| `legal_doc_url` | TEXT | `NULL` | — | URL atau path dokumen legalitas. |
| `bank_account_info` | JSONB | `NOT NULL` | — | Informasi rekening bank mitra. |
| `kyc_status` | ENUM | `pending`, `verified`, `rejected`; `NOT NULL`, default `pending` | — | Status verifikasi dokumen mitra. |
| `created_at` | TIMESTAMPTZ | `NOT NULL`, default `CURRENT_TIMESTAMP` | — | Waktu data mitra dibuat. |

## Tabel `destination_tickets`

| Atribut | Tipe data | Nilai / constraint | Key | Keterangan |
|---|---|---|---|---|
| `id` | UUID | `gen_random_uuid()` | Primary key | ID unik setiap jenis tiket. |
| `destination_id` | UUID | Referensi `destinations(id)` | Foreign key | Destinasi tempat tiket berlaku. Relasi komposit dengan `partner_id` memastikan mitra pengelola sesuai. |
| `partner_id` | UUID | Referensi `partners(id)` | Foreign key | Mitra pemilik atau pengelola tiket. |
| `ticket_name` | VARCHAR(100) | `NOT NULL` | — | Nama atau jenis tiket. |
| `visitor_type` | ENUM | `domestic`, `foreign`; `NOT NULL` | — | Kategori pengunjung. |
| `day_type` | ENUM | `weekday`, `weekend`; `NOT NULL` | — | Jenis hari berlakunya tiket. |
| `price` | NUMERIC(12,2) | `NOT NULL`, minimal `0` | — | Harga tiket. |
| `daily_quota` | INTEGER | `NOT NULL`, default `100`, minimal `0` | — | Jumlah kuota tiket per hari. |
| `is_active` | BOOLEAN | `NOT NULL`, default `TRUE` | — | Menunjukkan apakah tiket masih aktif. |

## Penjelasan Skema Database

### 1. Tabel `partners`

Tabel `partners` menyimpan profil mitra yang mendaftarkan diri sebagai pengelola destinasi wisata di platform NusantaraGo. Informasi yang disimpan mencakup akun pemilik, identitas usaha atau organisasi, kategori dan bentuk usaha, penanggung jawab, kontak, alamat, dokumen legalitas, rekening bank, serta status verifikasi KYC (*Know Your Customer*).

Atribut `user_id` menghubungkan profil mitra dengan akun pada tabel `users`. Constraint `UNIQUE` memastikan satu akun pengguna memiliki maksimal satu profil mitra.

Atribut `partner_type` mengidentifikasi kategori kegiatan mitra: `attraction`, `tour_agent`, `accommodation`, atau `transport`. Atribut `business_type` menunjukkan bentuk usaha atau organisasi pengelola, seperti desa wisata/Pokdarwis, BUMDes, PT, CV, koperasi, perorangan, yayasan, kelompok masyarakat, atau instansi pemerintah.

Atribut `person_in_charge`, `business_phone_number`, dan `business_address` menyimpan nama penanggung jawab, nomor telepon, dan alamat usaha atau organisasi. Atribut `legal_doc_url` menyimpan URL atau path dokumen legalitas, sedangkan `bank_account_info` menyimpan informasi rekening bank dalam format JSONB.

Atribut `kyc_status` menunjukkan status verifikasi dokumen legalitas. Nilai `pending` berarti menunggu pemeriksaan, `verified` berarti disetujui, dan `rejected` berarti ditolak. Atribut `created_at` mencatat waktu pembuatan data mitra.

### 2. Tabel `destination_tickets`

Tabel `destination_tickets` menyimpan jenis tiket yang ditawarkan mitra untuk suatu destinasi wisata. Informasinya mencakup destinasi dan mitra terkait, nama tiket, kategori pengunjung, jenis hari, harga, kuota harian, serta status aktif.

Atribut `partner_id` menghubungkan tiket dengan mitra pada tabel `partners`. Satu mitra dapat memiliki beberapa jenis tiket, sedangkan setiap tiket terkait dengan satu mitra.

Atribut `destination_id` menghubungkan tiket dengan destinasi pada tabel `destinations`. Satu destinasi dapat memiliki beberapa jenis tiket, sedangkan setiap tiket berlaku untuk satu destinasi.

Atribut `ticket_name` menyimpan nama atau jenis tiket. Atribut `visitor_type` membedakan pengunjung domestik (`domestic`) dan asing (`foreign`), sementara `day_type` membedakan hari kerja (`weekday`) dan akhir pekan (`weekend`). Atribut `price` menyimpan harga tiket, `daily_quota` menentukan jumlah maksimal tiket yang tersedia per hari, dan `is_active` menunjukkan apakah tiket masih ditawarkan.

## Relasi Antartabel

- **`users` ke `partners` — one-to-one (1:1):** satu akun pengguna dapat memiliki maksimal satu profil mitra. Relasi menggunakan `partners.user_id` yang mereferensikan `users.id`; constraint `UNIQUE` pada `user_id` menegakkan batas tersebut.
- **`partners` ke `destinations` — one-to-many (1:N):** satu mitra dapat mengelola beberapa destinasi. Relasi menggunakan `destinations.managed_by_partner_id` yang mereferensikan `partners.id`.
- **`partners` ke `destination_tickets` — one-to-many (1:N):** satu mitra dapat memiliki beberapa jenis tiket. Relasi menggunakan `destination_tickets.partner_id` yang mereferensikan `partners.id`.
- **`destinations` ke `destination_tickets` — one-to-many (1:N):** satu destinasi dapat memiliki beberapa jenis tiket. Relasi menggunakan `destination_tickets.destination_id` yang mereferensikan `destinations.id`.

Kombinasi `partner_id` dan `destination_id` pada `destination_tickets` harus cocok dengan mitra pengelola destinasi. Constraint foreign key komposit memastikan tiket hanya dimiliki oleh mitra yang mengelola destinasi tempat tiket berlaku.

## Kode Migrasi Database

### Tipe ENUM

```sql
CREATE TYPE partner_type_enum AS ENUM (
    'attraction',
    'tour_agent',
    'accommodation',
    'transport'
);

CREATE TYPE business_type_enum AS ENUM (
    'desa wisata/pokdarwis',
    'bumdes',
    'pt',
    'cv',
    'koperasi',
    'perorangan',
    'yayasan',
    'kelompok masyarakat',
    'instansi pemerintah'
);

CREATE TYPE kyc_status_enum AS ENUM (
    'pending',
    'verified',
    'rejected'
);

CREATE TYPE visitor_type_enum AS ENUM (
    'domestic',
    'foreign'
);

CREATE TYPE day_type_enum AS ENUM (
    'weekday',
    'weekend'
);
```

### Tabel `partners`

```sql
CREATE TABLE partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id),
    business_name VARCHAR(200) NOT NULL,
    partner_type partner_type_enum NOT NULL,
    business_type business_type_enum NOT NULL,
    person_in_charge VARCHAR(100) NOT NULL,
    business_phone_number VARCHAR(32) NOT NULL,
    business_address TEXT NOT NULL,
    legal_doc_url TEXT,
    bank_account_info JSONB NOT NULL,
    kyc_status kyc_status_enum NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_partners_kyc_status
    ON partners(kyc_status);
```

### Tabel `destination_tickets`

```sql
CREATE TABLE destination_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_id UUID NOT NULL REFERENCES partners(id),
    destination_id UUID NOT NULL,
    ticket_name VARCHAR(100) NOT NULL,
    visitor_type visitor_type_enum NOT NULL,
    day_type day_type_enum NOT NULL,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    daily_quota INTEGER NOT NULL DEFAULT 100 CHECK (daily_quota >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_ticket_destination_partner
        FOREIGN KEY (destination_id, partner_id)
        REFERENCES destinations (id, managed_by_partner_id)
);

CREATE INDEX idx_tickets_partner_id
    ON destination_tickets(partner_id);

CREATE INDEX idx_tickets_destination_id
    ON destination_tickets(destination_id);
```
