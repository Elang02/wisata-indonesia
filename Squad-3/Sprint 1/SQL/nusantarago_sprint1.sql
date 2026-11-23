-- =====================================================================
-- NusantaraGo - Sprint 1 - Squad 3
-- Skema basis data lengkap sesuai dokumen arsitektur (bagian 2, baris 83-229)
-- ditambah package_items sebagai relasi inti Squad 3.
--
-- Acuan:
--   docs/dokumen_arsitektur_dan_spesifikasi_teknis_nusantarago.md
--     :76-77  ekstensi postgis + uuid-ossp
--     :81     user_role, kyc_status_enum
--     :83-97  users
--     :97-110 partners (partner_type_enum)
--     :111-135 destinations (destination_status, GEOMETRY Point 4326)
--     :137-147 destination_tickets
--     :149-167 accommodations + accommodation_rooms
--     :169-178 transport_services
--     :180-195 tour_packages (itinerary_details JSONB)
--     :197-229 bookings, booking_items, escrow_ledgers
--   docs/blueprint_pengembangan_aplikasi_wisata_nusantarango.md
--     :88     package_items = tabel pivot penghubung destinations,
--             accommodation_rooms, dan transport_services
--   docs/roadmap_pengembangan_nusantarango_deadline_22_desember_2026.md
--     :35     tugas Squad 3 = desain relasi tour_packages dan package_items
--
-- Urutan tabel mengikuti ketergantungan foreign key, jadi file ini bisa
-- dimuat sekali jalan ke database kosong:
--   psql -v ON_ERROR_STOP=1 -f nusantarago_sprint1.sql
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Ekstensi
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------------------------------------------------------------------
-- 2. Tipe enumerasi
-- ---------------------------------------------------------------------
DO $$
BEGIN
    CREATE TYPE user_role AS ENUM ('tourist', 'partner', 'admin', 'guide');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
    CREATE TYPE kyc_status_enum AS ENUM ('unverified', 'pending', 'verified', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
    CREATE TYPE partner_type_enum AS ENUM ('attraction', 'tour_agent', 'accommodation', 'transport');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
    CREATE TYPE destination_status AS ENUM ('draft', 'pending', 'approved', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
    CREATE TYPE booking_status_enum AS ENUM
        ('unpaid', 'paid', 'confirmed', 'completed', 'cancelled', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
    CREATE TYPE escrow_status_enum AS ENUM ('held', 'disbursed', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Tipe khusus Squad 3 untuk isi paket
DO $$
BEGIN
    CREATE TYPE package_item_type AS ENUM ('destination', 'accommodation', 'transport');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------
-- 3. users : akun wisatawan, mitra, admin, pemandu
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role          user_role NOT NULL DEFAULT 'tourist',
    name          VARCHAR(150) NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone         VARCHAR(30),
    kyc_status    kyc_status_enum DEFAULT 'unverified',
    point_balance INT DEFAULT 0,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 4. partners : profil mitra penyedia jasa
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS partners (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_name     VARCHAR(200) NOT NULL,
    partner_type      partner_type_enum NOT NULL,
    legal_doc_url     TEXT,
    bank_account_info JSONB NOT NULL,
    is_verified       BOOLEAN DEFAULT FALSE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 5. destinations : objek wisata dengan koordinat PostGIS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS destinations (
    id                     UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    submitted_by_user_id   UUID REFERENCES users(id),
    managed_by_partner_id  UUID REFERENCES partners(id),
    name                   VARCHAR(200) NOT NULL,
    slug                   VARCHAR(250) UNIQUE NOT NULL,
    province_id            INT NOT NULL,
    regency_id             INT NOT NULL,
    category               VARCHAR(50) NOT NULL,
    coordinates            GEOMETRY(Point, 4326) NOT NULL,
    address                TEXT NOT NULL,
    description            TEXT NOT NULL,
    facilities             JSONB DEFAULT '{"toilet": true, "mushola": true, "parking": true, "cellular_signal": "strong"}'::jsonb,
    operating_hours        JSONB DEFAULT '{"open": "08:00", "close": "17:00", "timezone": "WIB"}'::jsonb,
    status                 destination_status DEFAULT 'pending',
    rating_avg             NUMERIC(3,2) DEFAULT 0.0,
    review_count           INT DEFAULT 0,
    created_at             TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_destinations_coordinates ON destinations USING GIST (coordinates);

-- ---------------------------------------------------------------------
-- 6. destination_tickets : harga tiket masuk per jenis pengunjung
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS destination_tickets (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    ticket_name   VARCHAR(100) NOT NULL,
    visitor_type  VARCHAR(20) NOT NULL,
    day_type      VARCHAR(20) NOT NULL,
    price         NUMERIC(12,2) NOT NULL,
    daily_quota   INT NOT NULL DEFAULT 100,
    is_active     BOOLEAN DEFAULT TRUE,
    CONSTRAINT destination_tickets_visitor_check
        CHECK (visitor_type IN ('domestic', 'foreign')),
    CONSTRAINT destination_tickets_day_check
        CHECK (day_type IN ('weekday', 'weekend')),
    CONSTRAINT destination_tickets_price_check CHECK (price >= 0)
);

-- ---------------------------------------------------------------------
-- 7. accommodations dan accommodation_rooms
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS accommodations (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_id    UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    name          VARCHAR(200) NOT NULL,
    property_type VARCHAR(50) NOT NULL,
    coordinates   GEOMETRY(Point, 4326) NOT NULL,
    address       TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_accommodations_coordinates ON accommodations USING GIST (coordinates);

CREATE TABLE IF NOT EXISTS accommodation_rooms (
    id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    accommodation_id       UUID NOT NULL REFERENCES accommodations(id) ON DELETE CASCADE,
    room_name              VARCHAR(100) NOT NULL,
    capacity_pax           INT NOT NULL DEFAULT 2,
    base_price_per_night   NUMERIC(12,2) NOT NULL,
    total_stock            INT NOT NULL DEFAULT 1,
    CONSTRAINT accommodation_rooms_capacity_check CHECK (capacity_pax > 0),
    CONSTRAINT accommodation_rooms_price_check CHECK (base_price_per_night >= 0)
);

-- ---------------------------------------------------------------------
-- 8. transport_services : kendaraan mitra
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transport_services (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_id          UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    vehicle_type        VARCHAR(50) NOT NULL,
    model_name          VARCHAR(100) NOT NULL,
    capacity_passengers INT NOT NULL,
    rental_scheme       VARCHAR(50) NOT NULL,
    price_per_day       NUMERIC(12,2) NOT NULL,
    CONSTRAINT transport_services_scheme_check
        CHECK (rental_scheme IN ('with_driver', 'self_drive', 'per_route')),
    CONSTRAINT transport_services_capacity_check CHECK (capacity_passengers > 0),
    CONSTRAINT transport_services_price_check CHECK (price_per_day >= 0)
);

-- ---------------------------------------------------------------------
-- 9. tour_packages : paket wisata yang dijual mitra (milik Squad 3)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tour_packages (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_id          UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    title               VARCHAR(250) NOT NULL,
    package_type        VARCHAR(30) NOT NULL DEFAULT 'open_trip',
    duration_days       INT NOT NULL DEFAULT 1,
    min_pax             INT NOT NULL DEFAULT 1,
    max_pax             INT NOT NULL DEFAULT 20,
    base_price          NUMERIC(12,2) NOT NULL DEFAULT 0,
    itinerary_details   JSONB NOT NULL DEFAULT '[]'::jsonb,
    cancellation_policy TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tour_packages_package_type_check
        CHECK (package_type IN ('open_trip', 'private_trip')),
    CONSTRAINT tour_packages_pax_check CHECK (max_pax >= min_pax AND min_pax > 0),
    CONSTRAINT tour_packages_duration_check CHECK (duration_days > 0),
    CONSTRAINT tour_packages_price_check CHECK (base_price >= 0)
);

COMMENT ON TABLE tour_packages IS 'Paket wisata (open trip / private trip) milik mitra';
COMMENT ON COLUMN tour_packages.itinerary_details IS
    'Rencana per hari: [{"day":1,"time":"09:00","activity":"Trekking","destination_id":"<uuid>"}]';

-- ---------------------------------------------------------------------
-- 10. package_items : isi paket (relasi inti Squad 3)
--     Satu baris = satu komponen paket pada hari tertentu.
--     item_type menentukan kolom target mana yang wajib terisi:
--       destination   -> destination_id
--       accommodation -> room_id
--       transport     -> transport_id
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS package_items (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    package_id     UUID NOT NULL REFERENCES tour_packages(id) ON DELETE CASCADE,
    item_type      package_item_type NOT NULL,
    destination_id UUID REFERENCES destinations(id) ON DELETE SET NULL,
    room_id        UUID REFERENCES accommodation_rooms(id) ON DELETE SET NULL,
    transport_id   UUID REFERENCES transport_services(id) ON DELETE SET NULL,
    day_number     SMALLINT NOT NULL DEFAULT 1,
    sort_order     SMALLINT NOT NULL DEFAULT 1,
    notes          TEXT,
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT package_items_target_check CHECK (
        (item_type = 'destination'   AND destination_id IS NOT NULL AND room_id IS NULL     AND transport_id IS NULL)
     OR (item_type = 'accommodation' AND room_id        IS NOT NULL AND destination_id IS NULL AND transport_id IS NULL)
     OR (item_type = 'transport'     AND transport_id   IS NOT NULL AND destination_id IS NULL AND room_id IS NULL)
    ),
    CONSTRAINT package_items_day_check CHECK (day_number > 0),
    CONSTRAINT package_items_sort_check CHECK (sort_order > 0)
);

COMMENT ON TABLE package_items IS
    'Tabel pivot isi paket: destinasi, kamar, atau transport per hari per paket';

-- ---------------------------------------------------------------------
-- 11. bookings dan booking_items
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bookings (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_code        VARCHAR(30) UNIQUE NOT NULL,
    user_id             UUID NOT NULL REFERENCES users(id),
    total_amount        NUMERIC(14,2) NOT NULL,
    status              booking_status_enum DEFAULT 'unpaid',
    payment_method      VARCHAR(50),
    payment_gateway_ref VARCHAR(100),
    qr_code_hash        VARCHAR(255) UNIQUE,
    expires_at          TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT bookings_amount_check CHECK (total_amount >= 0)
);

CREATE TABLE IF NOT EXISTS booking_items (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id        UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    item_type         VARCHAR(50) NOT NULL,
    item_reference_id UUID NOT NULL,
    visit_date        DATE NOT NULL,
    quantity          INT NOT NULL,
    price_per_unit    NUMERIC(12,2) NOT NULL,
    subtotal          NUMERIC(14,2) NOT NULL,
    CONSTRAINT booking_items_type_check
        CHECK (item_type IN ('ticket', 'package', 'accommodation', 'transport')),
    CONSTRAINT booking_items_quantity_check CHECK (quantity > 0),
    CONSTRAINT booking_items_amount_check CHECK (price_per_unit >= 0 AND subtotal >= 0)
);

-- ---------------------------------------------------------------------
-- 12. escrow_ledgers : buku besar dana yang ditahan platform
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS escrow_ledgers (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id     UUID NOT NULL REFERENCES bookings(id),
    partner_id     UUID NOT NULL REFERENCES partners(id),
    gross_amount   NUMERIC(14,2) NOT NULL,
    platform_fee   NUMERIC(14,2) NOT NULL,
    net_payout     NUMERIC(14,2) NOT NULL,
    status         escrow_status_enum DEFAULT 'held',
    disbursed_at   TIMESTAMP WITH TIME ZONE,
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT escrow_ledgers_amount_check
        CHECK (gross_amount >= 0 AND platform_fee >= 0 AND net_payout >= 0
               AND net_payout = gross_amount - platform_fee)
);

-- ---------------------------------------------------------------------
-- 13. Index pendukung query
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_partners_user                ON partners(user_id);
CREATE INDEX IF NOT EXISTS idx_destinations_status          ON destinations(status);
CREATE INDEX IF NOT EXISTS idx_destinations_category        ON destinations(category);
CREATE INDEX IF NOT EXISTS idx_destination_tickets_dest     ON destination_tickets(destination_id);
CREATE INDEX IF NOT EXISTS idx_accommodations_partner       ON accommodations(partner_id);
CREATE INDEX IF NOT EXISTS idx_rooms_accommodation          ON accommodation_rooms(accommodation_id);
CREATE INDEX IF NOT EXISTS idx_transport_partner            ON transport_services(partner_id);
CREATE INDEX IF NOT EXISTS idx_tour_packages_partner        ON tour_packages(partner_id);
CREATE INDEX IF NOT EXISTS idx_tour_packages_type           ON tour_packages(package_type);
CREATE INDEX IF NOT EXISTS idx_tour_packages_price          ON tour_packages(base_price);
CREATE INDEX IF NOT EXISTS idx_tour_packages_itinerary      ON tour_packages USING GIN (itinerary_details);
CREATE INDEX IF NOT EXISTS idx_package_items_package        ON package_items(package_id);
CREATE INDEX IF NOT EXISTS idx_package_items_day            ON package_items(package_id, day_number, sort_order);
CREATE INDEX IF NOT EXISTS idx_package_items_destination    ON package_items(destination_id)
    WHERE destination_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_package_items_room           ON package_items(room_id)
    WHERE room_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_package_items_transport      ON package_items(transport_id)
    WHERE transport_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_bookings_user                ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status              ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_booking_items_booking        ON booking_items(booking_id);
CREATE INDEX IF NOT EXISTS idx_escrow_booking               ON escrow_ledgers(booking_id);
CREATE INDEX IF NOT EXISTS idx_escrow_partner               ON escrow_ledgers(partner_id);

-- =====================================================================
-- 13b. Trigger updated_at
--      Kolom updated_at hanya berubah kalau ada trigger; tanpa ini nilainya
--      tetap sama selamanya walau baris diupdate berkali-kali.
-- =====================================================================
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_tour_packages_updated_at ON tour_packages;
CREATE TRIGGER trg_tour_packages_updated_at
    BEFORE UPDATE ON tour_packages
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- 14. Data contoh (opsional, aman diulang karena memakai UUID tetap)
-- =====================================================================
INSERT INTO users (id, role, name, email, password_hash, kyc_status)
VALUES
    ('11111111-1111-4111-8111-111111111111', 'partner', 'Budi Mitra Wisata',
     'budi@nusantarago.test', 'contoh-hash', 'verified'),
    ('11111111-1111-4111-8111-222222222222', 'tourist', 'Sari Wisatawan',
     'sari@nusantarago.test', 'contoh-hash', 'unverified')
ON CONFLICT (email) DO NOTHING;

INSERT INTO partners (id, user_id, business_name, partner_type, bank_account_info, is_verified)
VALUES
    ('22222222-2222-4222-8222-222222222222',
     '11111111-1111-4111-8111-111111111111',
     'Budi Tour & Travel', 'tour_agent',
     '{"bank_name":"BCA","account_number":"1234567890","account_holder":"Budi"}'::jsonb,
     TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO destinations
    (id, managed_by_partner_id, name, slug, province_id, regency_id, category,
     coordinates, address, description, status)
VALUES
    ('33333333-3333-4333-8333-333333333333',
     '22222222-2222-4222-8222-222222222222',
     'Kawah Ijen', 'kawah-ijen', 35, 3511, 'Alam',
     ST_SetSRID(ST_MakePoint(114.2422, -8.0583), 4326),
     'Banyuwangi, Jawa Timur', 'Kawah belerang dengan fenomena blue fire.', 'approved')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO accommodations (id, partner_id, name, property_type, coordinates, address)
VALUES
    ('44444444-4444-4444-8444-444444444444',
     '22222222-2222-4222-8222-222222222222',
     'Homestay Ijen View', 'homestay',
     ST_SetSRID(ST_MakePoint(114.2500, -8.0600), 4326),
     'Licin, Banyuwangi')
ON CONFLICT (id) DO NOTHING;

INSERT INTO accommodation_rooms
    (id, accommodation_id, room_name, capacity_pax, base_price_per_night, total_stock)
VALUES
    ('55555555-5555-4555-8555-555555555555',
     '44444444-4444-4444-8444-444444444444',
     'Kamar Double', 2, 350000, 5)
ON CONFLICT (id) DO NOTHING;

INSERT INTO transport_services
    (id, partner_id, vehicle_type, model_name, capacity_passengers, rental_scheme, price_per_day)
VALUES
    ('66666666-6666-4666-8666-666666666666',
     '22222222-2222-4222-8222-222222222222',
     'jeep', 'Toyota Hardtop', 6, 'with_driver', 750000)
ON CONFLICT (id) DO NOTHING;

INSERT INTO tour_packages
    (id, partner_id, title, package_type, duration_days, min_pax, max_pax,
     base_price, itinerary_details, cancellation_policy)
VALUES
    ('77777777-7777-4777-8777-777777777777',
     '22222222-2222-4222-8222-222222222222',
     'Ijen Midnight Trip 2D1N', 'open_trip', 2, 2, 12, 850000,
     '[{"day":1,"time":"23:00","activity":"Penjemputan dan perjalanan ke Paltuding","destination_id":"33333333-3333-4333-8333-333333333333"},
       {"day":2,"time":"02:00","activity":"Trekking ke kawah","destination_id":"33333333-3333-4333-8333-333333333333"}]'::jsonb,
     'Pembatalan H-3 potong 50 persen')
ON CONFLICT (id) DO NOTHING;

-- Isi paket: satu destinasi, satu kamar, satu transport
INSERT INTO package_items (id, package_id, item_type, destination_id, day_number, sort_order, notes)
VALUES
    ('88888888-8888-4888-8888-888888888888',
     '77777777-7777-4777-8777-777777777777',
     'destination', '33333333-3333-4333-8333-333333333333', 1, 1, 'Kawah Ijen')
ON CONFLICT (id) DO NOTHING;

INSERT INTO package_items (id, package_id, item_type, room_id, day_number, sort_order, notes)
VALUES
    ('88888888-8888-4888-8888-999999999999',
     '77777777-7777-4777-8777-777777777777',
     'accommodation', '55555555-5555-4555-8555-555555555555', 1, 2, 'Menginap sebelum trekking')
ON CONFLICT (id) DO NOTHING;

INSERT INTO package_items (id, package_id, item_type, transport_id, day_number, sort_order, notes)
VALUES
    ('99999999-9999-4999-8999-999999999999',
     '77777777-7777-4777-8777-777777777777',
     'transport', '66666666-6666-4666-8666-666666666666', 2, 3, 'Jeep ke Paltuding')
ON CONFLICT (id) DO NOTHING;

-- =====================================================================
-- Selesai. Verifikasi cepat setelah dimuat:
--   \dt                              -> 12 tabel
--   \d package_items                 -> 4 foreign key (package, destination, room, transport)
--   SELECT * FROM package_items ORDER BY day_number, sort_order;
-- =====================================================================
