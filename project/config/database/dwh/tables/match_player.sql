-- Table: dwh.match_player

-- DROP TABLE IF EXISTS dwh.match_player;

CREATE TABLE IF NOT EXISTS dwh.match_player
(
    match_id text COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default",
    player_id text COLLATE pg_catalog."default",
    team text COLLATE pg_catalog."default",
    is_captain boolean,
    is_wicketkeeper boolean,
    is_registered boolean DEFAULT true,
    is_substitute boolean,
    sub_type text COLLATE pg_catalog."default",
    player_id_num integer,
    CONSTRAINT match_player_uk UNIQUE (match_id, name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.match_player
    OWNER to postgres;