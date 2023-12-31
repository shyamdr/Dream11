-- Table: dwh.ground

-- DROP TABLE IF EXISTS dwh.ground;

CREATE TABLE IF NOT EXISTS dwh.ground
(
    ground_id serial,
    city text COLLATE pg_catalog."default",
    venue text COLLATE pg_catalog."default",
    country text COLLATE pg_catalog."default",
    region text COLLATE pg_catalog."default",
    active boolean DEFAULT true,
	longitude double precision,
    latitude double precision,
    CONSTRAINT ground_pk PRIMARY KEY (ground_id),
    CONSTRAINT ground_uk UNIQUE (venue)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.ground
    OWNER to postgres;