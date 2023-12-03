CREATE TABLE dwh.official
(
    match_id text,
    name text,
    official_id text,
    match_referees boolean,
    reserve_umpires boolean,
    umpires boolean,
    tv_umpires boolean,
    is_registered boolean DEFAULT TRUE,
    CONSTRAINT official_uk UNIQUE (match_id, name)
);

ALTER TABLE IF EXISTS dwh.official
    OWNER to postgres;