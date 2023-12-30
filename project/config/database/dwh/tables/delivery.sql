CREATE TABLE dwh.delivery
(
    match_id text NOT NULL,
    delivery_id smallint NOT NULL,
    inning smallint,
    team_id smallint,
    batter smallint,
    bowler smallint,
    non_striker smallint,
    run_batter smallint,
    run_extra smallint,
    run_total smallint,
    run_non_boundary boolean,
    over smallint,
    ball_num smallint,
    is_legal boolean,
    legal_ball_num smallint,
    is_replacement boolean,
    extra_wide smallint,
    extra_legbye smallint,
    extra_noball smallint,
    extra_bye smallint,
    extra_penalty smallint,
    is_review boolean,
    is_wicket boolean,
    CONSTRAINT delivery_pk PRIMARY KEY (match_id, delivery_id)
);

ALTER TABLE IF EXISTS dwh.delivery
    OWNER to postgres;