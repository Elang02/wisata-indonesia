--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4 (Debian 16.4-1.pgdg110+2)
-- Dumped by pg_dump version 16.4 (Debian 16.4-1.pgdg110+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.transport_services DROP CONSTRAINT IF EXISTS transport_services_partner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tour_packages DROP CONSTRAINT IF EXISTS tour_packages_partner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.partners DROP CONSTRAINT IF EXISTS partners_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_items DROP CONSTRAINT IF EXISTS package_items_transport_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_items DROP CONSTRAINT IF EXISTS package_items_room_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_items DROP CONSTRAINT IF EXISTS package_items_package_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_items DROP CONSTRAINT IF EXISTS package_items_destination_id_fkey;
ALTER TABLE IF EXISTS ONLY public.escrow_ledgers DROP CONSTRAINT IF EXISTS escrow_ledgers_partner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.escrow_ledgers DROP CONSTRAINT IF EXISTS escrow_ledgers_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.destinations DROP CONSTRAINT IF EXISTS destinations_submitted_by_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.destinations DROP CONSTRAINT IF EXISTS destinations_managed_by_partner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.destination_tickets DROP CONSTRAINT IF EXISTS destination_tickets_destination_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bookings DROP CONSTRAINT IF EXISTS bookings_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.booking_items DROP CONSTRAINT IF EXISTS booking_items_booking_id_fkey;
ALTER TABLE IF EXISTS ONLY public.accommodations DROP CONSTRAINT IF EXISTS accommodations_partner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.accommodation_rooms DROP CONSTRAINT IF EXISTS accommodation_rooms_accommodation_id_fkey;
DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS trg_tour_packages_updated_at ON public.tour_packages;
DROP INDEX IF EXISTS public.idx_transport_partner;
DROP INDEX IF EXISTS public.idx_tour_packages_type;
DROP INDEX IF EXISTS public.idx_tour_packages_price;
DROP INDEX IF EXISTS public.idx_tour_packages_partner;
DROP INDEX IF EXISTS public.idx_tour_packages_itinerary;
DROP INDEX IF EXISTS public.idx_rooms_accommodation;
DROP INDEX IF EXISTS public.idx_partners_user;
DROP INDEX IF EXISTS public.idx_package_items_transport;
DROP INDEX IF EXISTS public.idx_package_items_room;
DROP INDEX IF EXISTS public.idx_package_items_package;
DROP INDEX IF EXISTS public.idx_package_items_destination;
DROP INDEX IF EXISTS public.idx_package_items_day;
DROP INDEX IF EXISTS public.idx_escrow_partner;
DROP INDEX IF EXISTS public.idx_escrow_booking;
DROP INDEX IF EXISTS public.idx_destinations_status;
DROP INDEX IF EXISTS public.idx_destinations_coordinates;
DROP INDEX IF EXISTS public.idx_destinations_category;
DROP INDEX IF EXISTS public.idx_destination_tickets_dest;
DROP INDEX IF EXISTS public.idx_bookings_user;
DROP INDEX IF EXISTS public.idx_bookings_status;
DROP INDEX IF EXISTS public.idx_booking_items_booking;
DROP INDEX IF EXISTS public.idx_accommodations_partner;
DROP INDEX IF EXISTS public.idx_accommodations_coordinates;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.transport_services DROP CONSTRAINT IF EXISTS transport_services_pkey;
ALTER TABLE IF EXISTS ONLY public.tour_packages DROP CONSTRAINT IF EXISTS tour_packages_pkey;
ALTER TABLE IF EXISTS ONLY public.partners DROP CONSTRAINT IF EXISTS partners_pkey;
ALTER TABLE IF EXISTS ONLY public.package_items DROP CONSTRAINT IF EXISTS package_items_pkey;
ALTER TABLE IF EXISTS ONLY public.escrow_ledgers DROP CONSTRAINT IF EXISTS escrow_ledgers_pkey;
ALTER TABLE IF EXISTS ONLY public.destinations DROP CONSTRAINT IF EXISTS destinations_slug_key;
ALTER TABLE IF EXISTS ONLY public.destinations DROP CONSTRAINT IF EXISTS destinations_pkey;
ALTER TABLE IF EXISTS ONLY public.destination_tickets DROP CONSTRAINT IF EXISTS destination_tickets_pkey;
ALTER TABLE IF EXISTS ONLY public.bookings DROP CONSTRAINT IF EXISTS bookings_qr_code_hash_key;
ALTER TABLE IF EXISTS ONLY public.bookings DROP CONSTRAINT IF EXISTS bookings_pkey;
ALTER TABLE IF EXISTS ONLY public.bookings DROP CONSTRAINT IF EXISTS bookings_booking_code_key;
ALTER TABLE IF EXISTS ONLY public.booking_items DROP CONSTRAINT IF EXISTS booking_items_pkey;
ALTER TABLE IF EXISTS ONLY public.accommodations DROP CONSTRAINT IF EXISTS accommodations_pkey;
ALTER TABLE IF EXISTS ONLY public.accommodation_rooms DROP CONSTRAINT IF EXISTS accommodation_rooms_pkey;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.transport_services;
DROP TABLE IF EXISTS public.tour_packages;
DROP TABLE IF EXISTS public.partners;
DROP TABLE IF EXISTS public.package_items;
DROP TABLE IF EXISTS public.escrow_ledgers;
DROP TABLE IF EXISTS public.destinations;
DROP TABLE IF EXISTS public.destination_tickets;
DROP TABLE IF EXISTS public.bookings;
DROP TABLE IF EXISTS public.booking_items;
DROP TABLE IF EXISTS public.accommodations;
DROP TABLE IF EXISTS public.accommodation_rooms;
DROP FUNCTION IF EXISTS public.set_updated_at();
DROP TYPE IF EXISTS public.user_role;
DROP TYPE IF EXISTS public.partner_type_enum;
DROP TYPE IF EXISTS public.package_item_type;
DROP TYPE IF EXISTS public.kyc_status_enum;
DROP TYPE IF EXISTS public.escrow_status_enum;
DROP TYPE IF EXISTS public.destination_status;
DROP TYPE IF EXISTS public.booking_status_enum;
DROP EXTENSION IF EXISTS "uuid-ossp";
DROP EXTENSION IF EXISTS postgis;
--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: booking_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.booking_status_enum AS ENUM (
    'unpaid',
    'paid',
    'confirmed',
    'completed',
    'cancelled',
    'refunded'
);


--
-- Name: destination_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.destination_status AS ENUM (
    'draft',
    'pending',
    'approved',
    'rejected'
);


--
-- Name: escrow_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.escrow_status_enum AS ENUM (
    'held',
    'disbursed',
    'refunded'
);


--
-- Name: kyc_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.kyc_status_enum AS ENUM (
    'unverified',
    'pending',
    'verified',
    'rejected'
);


--
-- Name: package_item_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.package_item_type AS ENUM (
    'destination',
    'accommodation',
    'transport'
);


--
-- Name: partner_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.partner_type_enum AS ENUM (
    'attraction',
    'tour_agent',
    'accommodation',
    'transport'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'tourist',
    'partner',
    'admin',
    'guide'
);


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accommodation_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accommodation_rooms (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    accommodation_id uuid NOT NULL,
    room_name character varying(100) NOT NULL,
    capacity_pax integer DEFAULT 2 NOT NULL,
    base_price_per_night numeric(12,2) NOT NULL,
    total_stock integer DEFAULT 1 NOT NULL,
    CONSTRAINT accommodation_rooms_capacity_check CHECK ((capacity_pax > 0)),
    CONSTRAINT accommodation_rooms_price_check CHECK ((base_price_per_night >= (0)::numeric))
);


--
-- Name: accommodations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accommodations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    partner_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    property_type character varying(50) NOT NULL,
    coordinates public.geometry(Point,4326) NOT NULL,
    address text NOT NULL
);


--
-- Name: booking_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    booking_id uuid NOT NULL,
    item_type character varying(50) NOT NULL,
    item_reference_id uuid NOT NULL,
    visit_date date NOT NULL,
    quantity integer NOT NULL,
    price_per_unit numeric(12,2) NOT NULL,
    subtotal numeric(14,2) NOT NULL,
    CONSTRAINT booking_items_amount_check CHECK (((price_per_unit >= (0)::numeric) AND (subtotal >= (0)::numeric))),
    CONSTRAINT booking_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT booking_items_type_check CHECK (((item_type)::text = ANY ((ARRAY['ticket'::character varying, 'package'::character varying, 'accommodation'::character varying, 'transport'::character varying])::text[])))
);


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    booking_code character varying(30) NOT NULL,
    user_id uuid NOT NULL,
    total_amount numeric(14,2) NOT NULL,
    status public.booking_status_enum DEFAULT 'unpaid'::public.booking_status_enum,
    payment_method character varying(50),
    payment_gateway_ref character varying(100),
    qr_code_hash character varying(255),
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT bookings_amount_check CHECK ((total_amount >= (0)::numeric))
);


--
-- Name: destination_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.destination_tickets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    destination_id uuid NOT NULL,
    ticket_name character varying(100) NOT NULL,
    visitor_type character varying(20) NOT NULL,
    day_type character varying(20) NOT NULL,
    price numeric(12,2) NOT NULL,
    daily_quota integer DEFAULT 100 NOT NULL,
    is_active boolean DEFAULT true,
    CONSTRAINT destination_tickets_day_check CHECK (((day_type)::text = ANY ((ARRAY['weekday'::character varying, 'weekend'::character varying])::text[]))),
    CONSTRAINT destination_tickets_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT destination_tickets_visitor_check CHECK (((visitor_type)::text = ANY ((ARRAY['domestic'::character varying, 'foreign'::character varying])::text[])))
);


--
-- Name: destinations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.destinations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    submitted_by_user_id uuid,
    managed_by_partner_id uuid,
    name character varying(200) NOT NULL,
    slug character varying(250) NOT NULL,
    province_id integer NOT NULL,
    regency_id integer NOT NULL,
    category character varying(50) NOT NULL,
    coordinates public.geometry(Point,4326) NOT NULL,
    address text NOT NULL,
    description text NOT NULL,
    facilities jsonb DEFAULT '{"toilet": true, "mushola": true, "parking": true, "cellular_signal": "strong"}'::jsonb,
    operating_hours jsonb DEFAULT '{"open": "08:00", "close": "17:00", "timezone": "WIB"}'::jsonb,
    status public.destination_status DEFAULT 'pending'::public.destination_status,
    rating_avg numeric(3,2) DEFAULT 0.0,
    review_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: escrow_ledgers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.escrow_ledgers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    booking_id uuid NOT NULL,
    partner_id uuid NOT NULL,
    gross_amount numeric(14,2) NOT NULL,
    platform_fee numeric(14,2) NOT NULL,
    net_payout numeric(14,2) NOT NULL,
    status public.escrow_status_enum DEFAULT 'held'::public.escrow_status_enum,
    disbursed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT escrow_ledgers_amount_check CHECK (((gross_amount >= (0)::numeric) AND (platform_fee >= (0)::numeric) AND (net_payout >= (0)::numeric) AND (net_payout = (gross_amount - platform_fee))))
);


--
-- Name: package_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    package_id uuid NOT NULL,
    item_type public.package_item_type NOT NULL,
    destination_id uuid,
    room_id uuid,
    transport_id uuid,
    day_number smallint DEFAULT 1 NOT NULL,
    sort_order smallint DEFAULT 1 NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT package_items_day_check CHECK ((day_number > 0)),
    CONSTRAINT package_items_sort_check CHECK ((sort_order > 0)),
    CONSTRAINT package_items_target_check CHECK ((((item_type = 'destination'::public.package_item_type) AND (destination_id IS NOT NULL) AND (room_id IS NULL) AND (transport_id IS NULL)) OR ((item_type = 'accommodation'::public.package_item_type) AND (room_id IS NOT NULL) AND (destination_id IS NULL) AND (transport_id IS NULL)) OR ((item_type = 'transport'::public.package_item_type) AND (transport_id IS NOT NULL) AND (destination_id IS NULL) AND (room_id IS NULL))))
);


--
-- Name: TABLE package_items; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.package_items IS 'Tabel pivot isi paket: destinasi, kamar, atau transport per hari per paket';


--
-- Name: partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partners (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    business_name character varying(200) NOT NULL,
    partner_type public.partner_type_enum NOT NULL,
    legal_doc_url text,
    bank_account_info jsonb NOT NULL,
    is_verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: tour_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_packages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    partner_id uuid NOT NULL,
    title character varying(250) NOT NULL,
    package_type character varying(30) DEFAULT 'open_trip'::character varying NOT NULL,
    duration_days integer DEFAULT 1 NOT NULL,
    min_pax integer DEFAULT 1 NOT NULL,
    max_pax integer DEFAULT 20 NOT NULL,
    base_price numeric(12,2) DEFAULT 0 NOT NULL,
    itinerary_details jsonb DEFAULT '[]'::jsonb NOT NULL,
    cancellation_policy text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tour_packages_duration_check CHECK ((duration_days > 0)),
    CONSTRAINT tour_packages_package_type_check CHECK (((package_type)::text = ANY ((ARRAY['open_trip'::character varying, 'private_trip'::character varying])::text[]))),
    CONSTRAINT tour_packages_pax_check CHECK (((max_pax >= min_pax) AND (min_pax > 0))),
    CONSTRAINT tour_packages_price_check CHECK ((base_price >= (0)::numeric))
);


--
-- Name: TABLE tour_packages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tour_packages IS 'Paket wisata (open trip / private trip) milik mitra';


--
-- Name: COLUMN tour_packages.itinerary_details; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tour_packages.itinerary_details IS 'Rencana per hari: [{"day":1,"time":"09:00","activity":"Trekking","destination_id":"<uuid>"}]';


--
-- Name: transport_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transport_services (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    partner_id uuid NOT NULL,
    vehicle_type character varying(50) NOT NULL,
    model_name character varying(100) NOT NULL,
    capacity_passengers integer NOT NULL,
    rental_scheme character varying(50) NOT NULL,
    price_per_day numeric(12,2) NOT NULL,
    CONSTRAINT transport_services_capacity_check CHECK ((capacity_passengers > 0)),
    CONSTRAINT transport_services_price_check CHECK ((price_per_day >= (0)::numeric)),
    CONSTRAINT transport_services_scheme_check CHECK (((rental_scheme)::text = ANY ((ARRAY['with_driver'::character varying, 'self_drive'::character varying, 'per_route'::character varying])::text[])))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    role public.user_role DEFAULT 'tourist'::public.user_role NOT NULL,
    name character varying(150) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    phone character varying(30),
    kyc_status public.kyc_status_enum DEFAULT 'unverified'::public.kyc_status_enum,
    point_balance integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Data for Name: accommodation_rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accommodation_rooms (id, accommodation_id, room_name, capacity_pax, base_price_per_night, total_stock) FROM stdin;
55555555-5555-4555-8555-555555555555	44444444-4444-4444-8444-444444444444	Kamar Double	2	350000.00	5
\.


--
-- Data for Name: accommodations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accommodations (id, partner_id, name, property_type, coordinates, address) FROM stdin;
44444444-4444-4444-8444-444444444444	22222222-2222-4222-8222-222222222222	Homestay Ijen View	homestay	0101000020E61000000000000000905C401F85EB51B81E20C0	Licin, Banyuwangi
\.


--
-- Data for Name: booking_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.booking_items (id, booking_id, item_type, item_reference_id, visit_date, quantity, price_per_unit, subtotal) FROM stdin;
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookings (id, booking_code, user_id, total_amount, status, payment_method, payment_gateway_ref, qr_code_hash, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: destination_tickets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.destination_tickets (id, destination_id, ticket_name, visitor_type, day_type, price, daily_quota, is_active) FROM stdin;
\.


--
-- Data for Name: destinations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.destinations (id, submitted_by_user_id, managed_by_partner_id, name, slug, province_id, regency_id, category, coordinates, address, description, facilities, operating_hours, status, rating_avg, review_count, created_at) FROM stdin;
33333333-3333-4333-8333-333333333333	\N	22222222-2222-4222-8222-222222222222	Kawah Ijen	kawah-ijen	35	3511	Alam	0101000020E6100000D6C56D34808F5C40AEB6627FD91D20C0	Banyuwangi, Jawa Timur	Kawah belerang dengan fenomena blue fire.	{"toilet": true, "mushola": true, "parking": true, "cellular_signal": "strong"}	{"open": "08:00", "close": "17:00", "timezone": "WIB"}	approved	0.00	0	2026-11-21 16:48:49.42772+00
\.


--
-- Data for Name: escrow_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.escrow_ledgers (id, booking_id, partner_id, gross_amount, platform_fee, net_payout, status, disbursed_at, created_at) FROM stdin;
\.


--
-- Data for Name: package_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.package_items (id, package_id, item_type, destination_id, room_id, transport_id, day_number, sort_order, notes, created_at) FROM stdin;
88888888-8888-4888-8888-888888888888	77777777-7777-4777-8777-777777777777	destination	33333333-3333-4333-8333-333333333333	\N	\N	1	1	Kawah Ijen	2026-11-21 16:48:49.440946+00
88888888-8888-4888-8888-999999999999	77777777-7777-4777-8777-777777777777	accommodation	\N	55555555-5555-4555-8555-555555555555	\N	1	2	Menginap sebelum trekking	2026-11-21 16:48:49.474295+00
99999999-9999-4999-8999-999999999999	77777777-7777-4777-8777-777777777777	transport	\N	\N	66666666-6666-4666-8666-666666666666	2	3	Jeep ke Paltuding	2026-11-21 16:48:49.47659+00
\.


--
-- Data for Name: partners; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partners (id, user_id, business_name, partner_type, legal_doc_url, bank_account_info, is_verified, created_at) FROM stdin;
22222222-2222-4222-8222-222222222222	11111111-1111-4111-8111-111111111111	Budi Tour & Travel	tour_agent	\N	{"bank_name": "BCA", "account_holder": "Budi", "account_number": "1234567890"}	t	2026-11-21 16:48:49.42479+00
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: tour_packages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_packages (id, partner_id, title, package_type, duration_days, min_pax, max_pax, base_price, itinerary_details, cancellation_policy, created_at, updated_at) FROM stdin;
77777777-7777-4777-8777-777777777777	22222222-2222-4222-8222-222222222222	Ijen Midnight Trip 2D1N	open_trip	2	2	12	850000.00	[{"day": 1, "time": "23:00", "activity": "Penjemputan dan perjalanan ke Paltuding", "destination_id": "33333333-3333-4333-8333-333333333333"}, {"day": 2, "time": "02:00", "activity": "Trekking ke kawah", "destination_id": "33333333-3333-4333-8333-333333333333"}]	Pembatalan H-3 potong 50 persen	2026-11-21 16:48:49.434177+00	2026-11-21 16:48:49.434177+00
\.


--
-- Data for Name: transport_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transport_services (id, partner_id, vehicle_type, model_name, capacity_passengers, rental_scheme, price_per_day) FROM stdin;
66666666-6666-4666-8666-666666666666	22222222-2222-4222-8222-222222222222	jeep	Toyota Hardtop	6	with_driver	750000.00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, role, name, email, password_hash, phone, kyc_status, point_balance, created_at, updated_at) FROM stdin;
11111111-1111-4111-8111-111111111111	partner	Budi Mitra Wisata	budi@nusantarago.test	contoh-hash	\N	verified	0	2026-11-21 16:48:49.422979+00	2026-11-21 16:48:49.422979+00
11111111-1111-4111-8111-222222222222	tourist	Sari Wisatawan	sari@nusantarago.test	contoh-hash	\N	unverified	0	2026-11-21 16:48:49.422979+00	2026-11-21 16:48:49.422979+00
\.


--
-- Name: accommodation_rooms accommodation_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accommodation_rooms
    ADD CONSTRAINT accommodation_rooms_pkey PRIMARY KEY (id);


--
-- Name: accommodations accommodations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accommodations
    ADD CONSTRAINT accommodations_pkey PRIMARY KEY (id);


--
-- Name: booking_items booking_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_items
    ADD CONSTRAINT booking_items_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_booking_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_booking_code_key UNIQUE (booking_code);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_qr_code_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_qr_code_hash_key UNIQUE (qr_code_hash);


--
-- Name: destination_tickets destination_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destination_tickets
    ADD CONSTRAINT destination_tickets_pkey PRIMARY KEY (id);


--
-- Name: destinations destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_pkey PRIMARY KEY (id);


--
-- Name: destinations destinations_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_slug_key UNIQUE (slug);


--
-- Name: escrow_ledgers escrow_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escrow_ledgers
    ADD CONSTRAINT escrow_ledgers_pkey PRIMARY KEY (id);


--
-- Name: package_items package_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_pkey PRIMARY KEY (id);


--
-- Name: partners partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


--
-- Name: tour_packages tour_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_packages
    ADD CONSTRAINT tour_packages_pkey PRIMARY KEY (id);


--
-- Name: transport_services transport_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_services
    ADD CONSTRAINT transport_services_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_accommodations_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accommodations_coordinates ON public.accommodations USING gist (coordinates);


--
-- Name: idx_accommodations_partner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accommodations_partner ON public.accommodations USING btree (partner_id);


--
-- Name: idx_booking_items_booking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_booking_items_booking ON public.booking_items USING btree (booking_id);


--
-- Name: idx_bookings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_status ON public.bookings USING btree (status);


--
-- Name: idx_bookings_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_user ON public.bookings USING btree (user_id);


--
-- Name: idx_destination_tickets_dest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_destination_tickets_dest ON public.destination_tickets USING btree (destination_id);


--
-- Name: idx_destinations_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_destinations_category ON public.destinations USING btree (category);


--
-- Name: idx_destinations_coordinates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_destinations_coordinates ON public.destinations USING gist (coordinates);


--
-- Name: idx_destinations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_destinations_status ON public.destinations USING btree (status);


--
-- Name: idx_escrow_booking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_escrow_booking ON public.escrow_ledgers USING btree (booking_id);


--
-- Name: idx_escrow_partner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_escrow_partner ON public.escrow_ledgers USING btree (partner_id);


--
-- Name: idx_package_items_day; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_day ON public.package_items USING btree (package_id, day_number, sort_order);


--
-- Name: idx_package_items_destination; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_destination ON public.package_items USING btree (destination_id) WHERE (destination_id IS NOT NULL);


--
-- Name: idx_package_items_package; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_package ON public.package_items USING btree (package_id);


--
-- Name: idx_package_items_room; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_room ON public.package_items USING btree (room_id) WHERE (room_id IS NOT NULL);


--
-- Name: idx_package_items_transport; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_transport ON public.package_items USING btree (transport_id) WHERE (transport_id IS NOT NULL);


--
-- Name: idx_partners_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_partners_user ON public.partners USING btree (user_id);


--
-- Name: idx_rooms_accommodation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rooms_accommodation ON public.accommodation_rooms USING btree (accommodation_id);


--
-- Name: idx_tour_packages_itinerary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_packages_itinerary ON public.tour_packages USING gin (itinerary_details);


--
-- Name: idx_tour_packages_partner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_packages_partner ON public.tour_packages USING btree (partner_id);


--
-- Name: idx_tour_packages_price; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_packages_price ON public.tour_packages USING btree (base_price);


--
-- Name: idx_tour_packages_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_packages_type ON public.tour_packages USING btree (package_type);


--
-- Name: idx_transport_partner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transport_partner ON public.transport_services USING btree (partner_id);


--
-- Name: tour_packages trg_tour_packages_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_tour_packages_updated_at BEFORE UPDATE ON public.tour_packages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: users trg_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: accommodation_rooms accommodation_rooms_accommodation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accommodation_rooms
    ADD CONSTRAINT accommodation_rooms_accommodation_id_fkey FOREIGN KEY (accommodation_id) REFERENCES public.accommodations(id) ON DELETE CASCADE;


--
-- Name: accommodations accommodations_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accommodations
    ADD CONSTRAINT accommodations_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: booking_items booking_items_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_items
    ADD CONSTRAINT booking_items_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: destination_tickets destination_tickets_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destination_tickets
    ADD CONSTRAINT destination_tickets_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE CASCADE;


--
-- Name: destinations destinations_managed_by_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_managed_by_partner_id_fkey FOREIGN KEY (managed_by_partner_id) REFERENCES public.partners(id);


--
-- Name: destinations destinations_submitted_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations
    ADD CONSTRAINT destinations_submitted_by_user_id_fkey FOREIGN KEY (submitted_by_user_id) REFERENCES public.users(id);


--
-- Name: escrow_ledgers escrow_ledgers_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escrow_ledgers
    ADD CONSTRAINT escrow_ledgers_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id);


--
-- Name: escrow_ledgers escrow_ledgers_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escrow_ledgers
    ADD CONSTRAINT escrow_ledgers_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id);


--
-- Name: package_items package_items_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE SET NULL;


--
-- Name: package_items package_items_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.tour_packages(id) ON DELETE CASCADE;


--
-- Name: package_items package_items_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.accommodation_rooms(id) ON DELETE SET NULL;


--
-- Name: package_items package_items_transport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_transport_id_fkey FOREIGN KEY (transport_id) REFERENCES public.transport_services(id) ON DELETE SET NULL;


--
-- Name: partners partners_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tour_packages tour_packages_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_packages
    ADD CONSTRAINT tour_packages_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: transport_services transport_services_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_services
    ADD CONSTRAINT transport_services_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

