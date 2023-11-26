CREATE TABLE dwh.meta
(
    data_version text NOT NULL,
    created date,
    revision smallint,
    filename text,
    filetype text
);

ALTER TABLE IF EXISTS dwh.meta
    OWNER to postgres;