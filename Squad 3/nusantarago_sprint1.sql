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

--
-- Name: destination_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.destination_status AS ENUM (
    'pending',
    'approved',
    'rejected'
);


--
-- Name: package_item_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.package_item_type AS ENUM (
    'destination',
    'room',
    'transport'
);


--
-- Name: package_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.package_type AS ENUM (
    'open_trip',
    'private_trip'
);


--
-- Name: partner_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.partner_type AS ENUM (
    'attraction',
    'tour_agent',
    'accommodation',
    'transport'
);


--
-- Name: rental_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.rental_type AS ENUM (
    'lepas_kunci',
    'dengan_sopir',
    'per_rute'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accommodation_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accommodation_rooms (
    id bigint NOT NULL,
    accommodation_id bigint NOT NULL,
    room_type character varying(80) NOT NULL,
    capacity smallint NOT NULL,
    price_per_night numeric(12,2) NOT NULL,
    CONSTRAINT accommodation_rooms_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT accommodation_rooms_price_per_night_check CHECK ((price_per_night >= (0)::numeric))
);


--
-- Name: accommodation_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accommodation_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accommodation_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accommodation_rooms_id_seq OWNED BY public.accommodation_rooms.id;


--
-- Name: destinations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.destinations (
    id bigint NOT NULL,
    name character varying(160) NOT NULL,
    slug character varying(180) NOT NULL,
    status public.destination_status DEFAULT 'pending'::public.destination_status NOT NULL
);


--
-- Name: destinations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: destinations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.destinations_id_seq OWNED BY public.destinations.id;


--
-- Name: package_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_items (
    id bigint NOT NULL,
    package_id bigint NOT NULL,
    item_type public.package_item_type NOT NULL,
    destination_id bigint,
    room_id bigint,
    transport_id bigint,
    sort_order smallint DEFAULT 0 NOT NULL,
    CONSTRAINT package_items_target CHECK ((((item_type = 'destination'::public.package_item_type) AND (destination_id IS NOT NULL) AND (room_id IS NULL) AND (transport_id IS NULL)) OR ((item_type = 'room'::public.package_item_type) AND (room_id IS NOT NULL) AND (destination_id IS NULL) AND (transport_id IS NULL)) OR ((item_type = 'transport'::public.package_item_type) AND (transport_id IS NOT NULL) AND (destination_id IS NULL) AND (room_id IS NULL))))
);


--
-- Name: TABLE package_items; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.package_items IS 'Komponen penyusun paket wisata (Squad 3).';


--
-- Name: COLUMN package_items.item_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.package_items.item_type IS 'Menentukan kolom target: destination_id, room_id, atau transport_id.';


--
-- Name: package_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.package_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: package_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.package_items_id_seq OWNED BY public.package_items.id;


--
-- Name: partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partners (
    id bigint NOT NULL,
    business_name character varying(160) NOT NULL,
    partner_type public.partner_type NOT NULL,
    is_verified boolean DEFAULT false NOT NULL
);


--
-- Name: partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.partners_id_seq OWNED BY public.partners.id;


--
-- Name: tour_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_packages (
    id bigint NOT NULL,
    partner_id bigint NOT NULL,
    title character varying(160) NOT NULL,
    package_type public.package_type NOT NULL,
    duration_days smallint NOT NULL,
    min_pax smallint DEFAULT 1 NOT NULL,
    max_pax smallint NOT NULL,
    base_price numeric(12,2) NOT NULL,
    itinerary_details jsonb DEFAULT '[]'::jsonb NOT NULL,
    CONSTRAINT tour_packages_base_price_check CHECK ((base_price >= (0)::numeric)),
    CONSTRAINT tour_packages_duration_days_check CHECK ((duration_days > 0)),
    CONSTRAINT tour_packages_min_pax_check CHECK ((min_pax > 0)),
    CONSTRAINT tour_packages_pax_range CHECK ((max_pax >= min_pax))
);


--
-- Name: TABLE tour_packages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tour_packages IS 'Paket wisata yang dijual mitra (Squad 3).';


--
-- Name: COLUMN tour_packages.package_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tour_packages.package_type IS 'open_trip = gabung peserta lain; private_trip = satu grup sendiri.';


--
-- Name: tour_packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tour_packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tour_packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tour_packages_id_seq OWNED BY public.tour_packages.id;


--
-- Name: transport_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transport_services (
    id bigint NOT NULL,
    vehicle_type character varying(80) NOT NULL,
    rental_type public.rental_type NOT NULL,
    tariff numeric(12,2) NOT NULL,
    CONSTRAINT transport_services_tariff_check CHECK ((tariff >= (0)::numeric))
);


--
-- Name: transport_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transport_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transport_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transport_services_id_seq OWNED BY public.transport_services.id;


--
-- Name: accommodation_rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accommodation_rooms ALTER COLUMN id SET DEFAULT nextval('public.accommodation_rooms_id_seq'::regclass);


--
-- Name: destinations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destinations ALTER COLUMN id SET DEFAULT nextval('public.destinations_id_seq'::regclass);


--
-- Name: package_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items ALTER COLUMN id SET DEFAULT nextval('public.package_items_id_seq'::regclass);


--
-- Name: partners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners ALTER COLUMN id SET DEFAULT nextval('public.partners_id_seq'::regclass);


--
-- Name: tour_packages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_packages ALTER COLUMN id SET DEFAULT nextval('public.tour_packages_id_seq'::regclass);


--
-- Name: transport_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_services ALTER COLUMN id SET DEFAULT nextval('public.transport_services_id_seq'::regclass);


--
-- Data for Name: accommodation_rooms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accommodation_rooms (id, accommodation_id, room_type, capacity, price_per_night) FROM stdin;
1	2	Deluxe Twin	2	450000.00
2	2	Family Suite	4	850000.00
\.


--
-- Data for Name: destinations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.destinations (id, name, slug, status) FROM stdin;
1	Kawah Putih	kawah-putih	approved
2	Situ Patenggang	situ-patenggang	approved
3	Orchid Forest Cikole	orchid-forest-cikole	approved
\.


--
-- Data for Name: package_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.package_items (id, package_id, item_type, destination_id, room_id, transport_id, sort_order) FROM stdin;
1	1	destination	1	\N	\N	1
2	1	destination	2	\N	\N	2
3	1	transport	\N	\N	1	3
4	2	destination	1	\N	\N	1
5	2	room	\N	1	\N	2
6	2	transport	\N	\N	1	3
7	2	destination	3	\N	\N	4
\.


--
-- Data for Name: partners; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partners (id, business_name, partner_type, is_verified) FROM stdin;
1	PT Bandung Tour Partner	tour_agent	t
2	Villa Patenggang Hospitality	accommodation	t
\.


--
-- Data for Name: tour_packages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_packages (id, partner_id, title, package_type, duration_days, min_pax, max_pax, base_price, itinerary_details) FROM stdin;
1	1	Open Trip Kawah Putih 1D	open_trip	1	2	12	350000.00	[{"day": 1, "items": ["Kawah Putih", "Situ Patenggang"]}]
2	1	Private Trip Bandung Selatan 2D1N	private_trip	2	2	6	1250000.00	[{"day": 1, "items": ["Kawah Putih", "Check-in Villa Patenggang"]}, {"day": 2, "items": ["Situ Patenggang", "Orchid Forest Cikole"]}]
\.


--
-- Data for Name: transport_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transport_services (id, vehicle_type, rental_type, tariff) FROM stdin;
1	Toyota Hiace	dengan_sopir	1200000.00
2	Toyota Avanza	lepas_kunci	450000.00
\.


--
-- Name: accommodation_rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.accommodation_rooms_id_seq', 2, true);


--
-- Name: destinations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.destinations_id_seq', 3, true);


--
-- Name: package_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.package_items_id_seq', 7, true);


--
-- Name: partners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.partners_id_seq', 2, true);


--
-- Name: tour_packages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tour_packages_id_seq', 2, true);


--
-- Name: transport_services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transport_services_id_seq', 2, true);


--
-- Name: accommodation_rooms accommodation_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accommodation_rooms
    ADD CONSTRAINT accommodation_rooms_pkey PRIMARY KEY (id);


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
-- Name: idx_package_items_destination; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_destination ON public.package_items USING btree (destination_id);


--
-- Name: idx_package_items_package; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_package ON public.package_items USING btree (package_id, sort_order);


--
-- Name: idx_package_items_room; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_room ON public.package_items USING btree (room_id);


--
-- Name: idx_package_items_transport; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_items_transport ON public.package_items USING btree (transport_id);


--
-- Name: idx_tour_packages_partner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_packages_partner ON public.tour_packages USING btree (partner_id);


--
-- Name: idx_tour_packages_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_packages_type ON public.tour_packages USING btree (package_type);


--
-- Name: package_items package_items_destination_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_destination_id_fkey FOREIGN KEY (destination_id) REFERENCES public.destinations(id) ON DELETE RESTRICT;


--
-- Name: package_items package_items_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.tour_packages(id) ON DELETE CASCADE;


--
-- Name: package_items package_items_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.accommodation_rooms(id) ON DELETE RESTRICT;


--
-- Name: package_items package_items_transport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_items
    ADD CONSTRAINT package_items_transport_id_fkey FOREIGN KEY (transport_id) REFERENCES public.transport_services(id) ON DELETE RESTRICT;


--
-- Name: tour_packages tour_packages_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_packages
    ADD CONSTRAINT tour_packages_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

