CREATE TABLE dwh.urls
(
    site text,
    url_type text,
    season text,
    series text,
    match text,
    match_attr text,
    endpoint text,
    url text NOT NULL
);

ALTER TABLE IF EXISTS dwh.urls
    OWNER to postgres;

COMMENT ON TABLE dwh.urls
    IS 'site - ESPNCricInfo, Cricbuzz
url_type - season, series, match, match_attr
season - season name
series - series name
match - match_id
match_attr - playing XI, squad, scorecard, fantasy etc
';