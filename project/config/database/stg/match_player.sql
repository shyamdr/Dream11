-- Table: stg.match_player

-- DROP TABLE IF EXISTS stg.match_player;

CREATE TABLE IF NOT EXISTS stg.match_player
(
    match_id text COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default",
    player_id text COLLATE pg_catalog."default",
    team text COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS stg.match_player
    OWNER to postgres;