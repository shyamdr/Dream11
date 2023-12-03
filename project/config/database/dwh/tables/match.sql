CREATE TABLE dwh.match
(
    match_id text NOT NULL,
    balls_per_over smallint,
    event_id integer,
    season text,
    gender text,
    ground_id smallint,
    start_date date,
    end_date date,
    match_type text,
    match_type_num integer,
    overs numeric(4, 1),
    player_of_match text,
    team_type text,
    host text,
    visitor text,
    toss_winner text,
    toss_decision text,
    toss_uncontested boolean,
    outcome_winner text,
    outcome_by_wickets smallint,
    outcome_by_runs smallint,
    outcome_by_innings smallint,
    outcome_result text,
    outcome_eliminator text,
    outcome_method text,
    outcome_bowl_out text,
    event_match_number smallint,
    event_group text,
    event_stage text,
    CONSTRAINT match_pk PRIMARY KEY (match_id)
);

ALTER TABLE IF EXISTS dwh.match
    OWNER to postgres;