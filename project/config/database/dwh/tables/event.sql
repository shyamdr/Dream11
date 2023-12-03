CREATE TABLE dwh.event
(
    event_id serial NOT NULL,
    name text,
    season text,
    type text,
    CONSTRAINT event_pk PRIMARY KEY (event_id),
    CONSTRAINT event_uk UNIQUE (name, season)
);

ALTER TABLE IF EXISTS dwh.event
    OWNER to postgres;