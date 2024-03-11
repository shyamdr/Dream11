CREATE TABLE IF NOT EXISTS dwh.player_info
(
    id smallint NOT NULL,
    identifier text COLLATE pg_catalog."default",
    key_cricinfo text COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default",
    full_name text COLLATE pg_catalog."default",
    dob date,
    birth_place text COLLATE pg_catalog."default",
    batting_hand text COLLATE pg_catalog."default",
    bowling_hand text COLLATE pg_catalog."default",
    bowling_style text COLLATE pg_catalog."default",
    fielding_pos text COLLATE pg_catalog."default",
    role text COLLATE pg_catalog."default",
    url text COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.player_info
    OWNER to postgres;