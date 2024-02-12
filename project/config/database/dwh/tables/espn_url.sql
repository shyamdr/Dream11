CREATE TABLE IF NOT EXISTS dwh.espn_url
(
    url_type text COLLATE pg_catalog."default",
    season text COLLATE pg_catalog."default",
    series text COLLATE pg_catalog."default",
    match text COLLATE pg_catalog."default",
    url text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT uk_espn_url UNIQUE (url_type, season, series, match, url)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.espn_url
    OWNER to postgres;

COMMENT ON TABLE dwh.espn_url
    IS 'site - ESPNCricInfo, Cricbuzz
url_type - season, series, match, match_attr
season - season name
series - series name
match - match_id
';