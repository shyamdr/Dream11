CREATE TABLE IF NOT EXISTS dwh.replacement
(
    match_id text COLLATE pg_catalog."default" NOT NULL,
    delivery_id smallint NOT NULL,
    team_id smallint,
    replacement_type text COLLATE pg_catalog."default",
    "in" smallint NOT NULL,
    "out" smallint,
    reason text COLLATE pg_catalog."default",
    role text COLLATE pg_catalog."default",
    CONSTRAINT replacement_pk PRIMARY KEY (match_id, delivery_id, "in")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.replacement
    OWNER to postgres;