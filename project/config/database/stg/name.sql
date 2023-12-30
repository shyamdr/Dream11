CREATE TABLE stg.name
(
    identifier text,
    name text
);

ALTER TABLE IF EXISTS stg.name
    OWNER to postgres;