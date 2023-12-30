CREATE TABLE stg.people
(
    identifier text NOT NULL,
    name text NOT NULL,
    unique_name text NOT NULL,
    key_bcci text,
    key_bcci_2 text,
    key_bigbash text,
    key_cricbuzz text,
	key_cricheroes text,
    key_crichq text,
    key_cricinfo text,
    key_cricinfo_2 text,
    key_cricingif text,
    key_cricketarchive text,
    key_cricketarchive_2 text,
	key_nvplay text,
    key_opta text,
    key_opta_2 text,
    key_pulse text,
    key_pulse_2 text
);

ALTER TABLE IF EXISTS stg.people
    OWNER to postgres;