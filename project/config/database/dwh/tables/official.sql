CREATE TABLE IF NOT EXISTS dwh.official
(
    match_id text COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default",
    official_id text,
	official_id_num integer,
    match_referees boolean,
    reserve_umpires boolean,
    umpires boolean,
    tv_umpires boolean,
    is_registered boolean DEFAULT true,
    CONSTRAINT official_uk UNIQUE (match_id, name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.official
    OWNER to postgres;