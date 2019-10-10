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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: character_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_items (
    id bigint NOT NULL,
    character_id bigint NOT NULL,
    item_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: character_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_items_id_seq OWNED BY public.character_items.id;


--
-- Name: character_traits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_traits (
    id bigint NOT NULL,
    character_id bigint NOT NULL,
    trait_id bigint NOT NULL,
    value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: character_traits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_traits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_traits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_traits_id_seq OWNED BY public.character_traits.id;


--
-- Name: characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.characters (
    id bigint NOT NULL,
    name public.citext NOT NULL,
    description character varying NOT NULL,
    universe_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.characters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.characters_id_seq OWNED BY public.characters.id;


--
-- Name: collaborations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collaborations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    universe_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collaborations_id_seq OWNED BY public.collaborations.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id bigint NOT NULL,
    name public.citext NOT NULL,
    description character varying NOT NULL,
    universe_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: mutual_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mutual_relationships (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: mutual_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mutual_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mutual_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mutual_relationships_id_seq OWNED BY public.mutual_relationships.id;


--
-- Name: relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relationships (
    id bigint NOT NULL,
    mutual_relationship_id bigint NOT NULL,
    originating_character_id bigint NOT NULL,
    target_character_id bigint NOT NULL,
    name public.citext NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT relationships_no_self_relationships CHECK ((originating_character_id <> target_character_id))
);


--
-- Name: relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.relationships_id_seq OWNED BY public.relationships.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: traits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.traits (
    id bigint NOT NULL,
    name public.citext NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: traits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.traits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: traits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.traits_id_seq OWNED BY public.traits.id;


--
-- Name: universes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.universes (
    id bigint NOT NULL,
    name public.citext NOT NULL,
    owner_id bigint NOT NULL,
    discarded_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: universes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.universes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: universes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.universes_id_seq OWNED BY public.universes.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    display_name public.citext NOT NULL,
    password_digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: character_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items ALTER COLUMN id SET DEFAULT nextval('public.character_items_id_seq'::regclass);


--
-- Name: character_traits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_traits ALTER COLUMN id SET DEFAULT nextval('public.character_traits_id_seq'::regclass);


--
-- Name: characters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters ALTER COLUMN id SET DEFAULT nextval('public.characters_id_seq'::regclass);


--
-- Name: collaborations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collaborations ALTER COLUMN id SET DEFAULT nextval('public.collaborations_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: mutual_relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mutual_relationships ALTER COLUMN id SET DEFAULT nextval('public.mutual_relationships_id_seq'::regclass);


--
-- Name: relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships ALTER COLUMN id SET DEFAULT nextval('public.relationships_id_seq'::regclass);


--
-- Name: traits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traits ALTER COLUMN id SET DEFAULT nextval('public.traits_id_seq'::regclass);


--
-- Name: universes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universes ALTER COLUMN id SET DEFAULT nextval('public.universes_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: character_items character_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items
    ADD CONSTRAINT character_items_pkey PRIMARY KEY (id);


--
-- Name: character_traits character_traits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_traits
    ADD CONSTRAINT character_traits_pkey PRIMARY KEY (id);


--
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- Name: collaborations collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collaborations
    ADD CONSTRAINT collaborations_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: mutual_relationships mutual_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mutual_relationships
    ADD CONSTRAINT mutual_relationships_pkey PRIMARY KEY (id);


--
-- Name: relationships relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT relationships_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: traits traits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.traits
    ADD CONSTRAINT traits_pkey PRIMARY KEY (id);


--
-- Name: universes universes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universes
    ADD CONSTRAINT universes_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_character_items_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_items_on_character_id ON public.character_items USING btree (character_id);


--
-- Name: index_character_items_on_character_id_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_character_items_on_character_id_and_item_id ON public.character_items USING btree (character_id, item_id);


--
-- Name: index_character_items_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_items_on_item_id ON public.character_items USING btree (item_id);


--
-- Name: index_character_traits_on_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_traits_on_character_id ON public.character_traits USING btree (character_id);


--
-- Name: index_character_traits_on_character_id_and_trait_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_character_traits_on_character_id_and_trait_id ON public.character_traits USING btree (character_id, trait_id);


--
-- Name: index_character_traits_on_trait_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_character_traits_on_trait_id ON public.character_traits USING btree (trait_id);


--
-- Name: index_characters_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_discarded_at ON public.characters USING btree (discarded_at);


--
-- Name: index_characters_on_name_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_characters_on_name_and_universe_id ON public.characters USING btree (name, universe_id);


--
-- Name: index_characters_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_characters_on_universe_id ON public.characters USING btree (universe_id);


--
-- Name: index_collaborations_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collaborations_on_universe_id ON public.collaborations USING btree (universe_id);


--
-- Name: index_collaborations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collaborations_on_user_id ON public.collaborations USING btree (user_id);


--
-- Name: index_collaborations_on_user_id_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collaborations_on_user_id_and_universe_id ON public.collaborations USING btree (user_id, universe_id);


--
-- Name: index_items_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_items_on_name ON public.items USING btree (name);


--
-- Name: index_locations_on_name_and_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locations_on_name_and_universe_id ON public.locations USING btree (name, universe_id);


--
-- Name: index_locations_on_universe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_universe_id ON public.locations USING btree (universe_id);


--
-- Name: index_relationships_on_mutual_relationship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_relationships_on_mutual_relationship_id ON public.relationships USING btree (mutual_relationship_id);


--
-- Name: index_relationships_on_originating_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_relationships_on_originating_character_id ON public.relationships USING btree (originating_character_id);


--
-- Name: index_relationships_on_target_character_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_relationships_on_target_character_id ON public.relationships USING btree (target_character_id);


--
-- Name: index_traits_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_traits_on_name ON public.traits USING btree (name);


--
-- Name: index_universes_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_universes_on_discarded_at ON public.universes USING btree (discarded_at);


--
-- Name: index_universes_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_universes_on_name ON public.universes USING btree (name);


--
-- Name: index_universes_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_universes_on_owner_id ON public.universes USING btree (owner_id);


--
-- Name: index_users_on_display_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_display_name ON public.users USING btree (display_name);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: relationships_unique_constraint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX relationships_unique_constraint ON public.relationships USING btree (originating_character_id, target_character_id, name);


--
-- Name: relationships fk_rails_0a2e452fb3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT fk_rails_0a2e452fb3 FOREIGN KEY (originating_character_id) REFERENCES public.characters(id);


--
-- Name: universes fk_rails_136568e844; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universes
    ADD CONSTRAINT fk_rails_136568e844 FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: character_traits fk_rails_1716cd6513; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_traits
    ADD CONSTRAINT fk_rails_1716cd6513 FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: relationships fk_rails_1a92435ef5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT fk_rails_1a92435ef5 FOREIGN KEY (target_character_id) REFERENCES public.characters(id);


--
-- Name: character_items fk_rails_c1dafae0c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items
    ADD CONSTRAINT fk_rails_c1dafae0c9 FOREIGN KEY (character_id) REFERENCES public.characters(id);


--
-- Name: locations fk_rails_d649f80004; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT fk_rails_d649f80004 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: character_traits fk_rails_e5d8754c37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_traits
    ADD CONSTRAINT fk_rails_e5d8754c37 FOREIGN KEY (trait_id) REFERENCES public.traits(id);


--
-- Name: characters fk_rails_e7093ff482; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT fk_rails_e7093ff482 FOREIGN KEY (universe_id) REFERENCES public.universes(id);


--
-- Name: character_items fk_rails_ffe3de2639; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_items
    ADD CONSTRAINT fk_rails_ffe3de2639 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20191001214947'),
('20191008195955');


