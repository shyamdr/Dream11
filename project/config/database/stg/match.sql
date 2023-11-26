CREATE TABLE stg.match
(
    match_id text NOT NULL,
	balls_per_over smallint,
    event_name text,
    event_match_number smallint,
    event_group text,
    event_stage text,
    season text,
    match_num smallint,
    gender text,
    city text,
    venue text,
    start_date date,
    end_date date,
    match_type text,
    match_type_number smallint,
    overs numeric(4, 1),
    player_of_match text,
    outcome_winner text,
    outcome_by_wickets smallint,
    outcome_by_runs smallint,
    outcome_by_innings smallint,
    outcome_result text,
    outcome_eliminator text,
    outcome_method text,
    outcome_bowl_out text,
    team_type text,
    team_host text,
    team_visitor text,
    toss_decision text,
    toss_winner text,
    toss_uncontested boolean,
    CONSTRAINT match_id_pk PRIMARY KEY (match_id)
);

ALTER TABLE IF EXISTS stg.match
    OWNER to postgres;