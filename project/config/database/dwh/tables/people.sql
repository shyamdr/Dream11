CREATE TABLE dwh.people
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
    key_opta text,
    key_opta_2 text,
    key_pulse text,
    key_pulse_2 text,
    CONSTRAINT people_pk PRIMARY KEY (identifier)
);

ALTER TABLE IF EXISTS dwh.people
    OWNER to postgres;