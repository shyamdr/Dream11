CREATE TABLE dwh.replacement
(
    match_id text NOT NULL,
    delivery_id smallint NOT NULL,
    team_id smallint,
    replacement_type text,
    "in" smallint,
    "out" smallint,
    reason text,
    role text,
    CONSTRAINT replacement_pk PRIMARY KEY (match_id, delivery_id, "out")
);

ALTER TABLE IF EXISTS dwh.replacement
    OWNER to postgres;