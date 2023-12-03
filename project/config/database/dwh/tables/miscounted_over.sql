CREATE TABLE dwh.miscounted_over
(
    match_id text,
    team text,
    miscounted_over text,
    balls smallint,
    umpire text,
    CONSTRAINT miscounted_over_uk UNIQUE (match_id, team, miscounted_over, balls, umpire)
);

ALTER TABLE IF EXISTS dwh.miscounted_over
    OWNER to postgres;