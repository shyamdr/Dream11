CREATE TABLE stg.delivery
(
	index integer,
    match_id text NOT NULL,
	inning smallint,
	team text,
    batter text,
    bowler text,
    non_striker text,
    runs_batter smallint,
    runs_extras smallint,
    runs_total smallint,
    runs_non_boundary boolean,
    overs_over smallint,
    replacements_match json,
    replacements_role json,
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
    wickets json
);

ALTER TABLE IF EXISTS stg.delivery
    OWNER to postgres;