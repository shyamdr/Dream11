CREATE TABLE dwh.powerplay
(
    powerplay_id serial NOT NULL,
    match_id text,
    match_type text,
    team text,
    type text,
    "from" numeric(4, 1),
    "to" numeric(4, 1),
    CONSTRAINT powerplay_pk PRIMARY KEY (powerplay_id)
);

ALTER TABLE IF EXISTS dwh.powerplay
    OWNER to postgres;