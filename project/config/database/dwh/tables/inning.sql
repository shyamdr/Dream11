CREATE TABLE dwh.inning
(
    inning_id text NOT NULL,
    match_id text,
    team text,
    penalty_runs_pre smallint,
    penalty_runs_post smallint,
    declared boolean,
    forfeited boolean,
    target_overs numeric(4, 1),
    target_runs smallint,
    super_over boolean,
    CONSTRAINT inning_pk PRIMARY KEY (inning_id)
);

ALTER TABLE IF EXISTS dwh.inning
    OWNER to postgres;