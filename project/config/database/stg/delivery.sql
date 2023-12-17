CREATE TABLE stg.delivery
(
    match_id text NOT NULL,
	inning smallint,
    team text,
    batter text,
    bowler text,
    non_striker text,
    runs_batter smallint,
    runs_extras smallint,
    runs_total smallint,
    runs_non_boundary smallint,
    overs_over smallint,
    replacements_match text,
    replacements_role text,
    extras_wides smallint,
    extras_legbyes smallint,
    extras_noballs smallint,
    extras_byes smallint,
    extras_penalty smallint,
    review_by text,
    review_umpire text,
    review_batter text,
    review_decision text,
    review_type text,
    review_umpires_call text,
    wickets text
);

ALTER TABLE IF EXISTS stg.delivery
    OWNER to postgres;