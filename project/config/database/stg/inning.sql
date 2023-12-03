CREATE TABLE stg.inning
(
    match_id text,
    team text,
    absent_hurt text,
    penalty_runs_pre smallint,
    penalty_runs_post smallint,
    declared boolean,
    forfeited boolean,
    target_overs numeric(4, 1),
    target_runs smallint,
    super_over boolean
);

ALTER TABLE IF EXISTS stg.inning
    OWNER to postgres;