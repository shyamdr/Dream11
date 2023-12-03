CREATE TABLE stg.powerplay
(
    match_id text,
    team text,
    type text,
    "from" numeric(3, 1),
    "to" numeric(3, 1)
);

ALTER TABLE IF EXISTS stg.powerplay
    OWNER to postgres;