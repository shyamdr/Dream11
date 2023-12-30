CREATE TABLE dwh.review
(
    match_id text NOT NULL,
    delivery_id smallint NOT NULL,
    team_id smallint,
    review_umpire smallint,
    review_batter smallint,
    review_decision text,
    review_type text,
    review_umpires_call boolean,
    CONSTRAINT review_pk PRIMARY KEY (match_id, delivery_id)
);

ALTER TABLE IF EXISTS dwh.review
    OWNER to postgres;