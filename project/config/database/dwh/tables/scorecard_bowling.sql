-- Table: dwh.scorecard_bowling

-- DROP TABLE IF EXISTS dwh.scorecard_bowling;

CREATE TABLE IF NOT EXISTS dwh.scorecard_bowling
(
    match_type text COLLATE pg_catalog."default",
    match_id text COLLATE pg_catalog."default" NOT NULL,
    team_id smallint,
    inning smallint,
    bowler smallint NOT NULL,
    bowler_name text COLLATE pg_catalog."default",
    total_score numeric(6,3),
    balls_bowled smallint,
    runs_given smallint,
    expected_runs_given numeric(6,3),
    wickets smallint,
    smart_wickets numeric(5,3),
    dot_balls smallint,
    smart_dot_balls_per_over numeric(3,2),
    smart_bowling_strikerate numeric,
    bowling_average numeric,
    CONSTRAINT pk_bowling_match_score PRIMARY KEY (match_id, bowler),
    CONSTRAINT fk_match FOREIGN KEY (match_id)
        REFERENCES dwh.match (match_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.scorecard_bowling
    OWNER to postgres;