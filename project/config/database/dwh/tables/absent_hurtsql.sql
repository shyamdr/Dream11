CREATE TABLE dwh.absent_hurt
(
    match_id text,
    player_id text,
    name text,
    team text,
    CONSTRAINT absent_hurt_uk UNIQUE (match_id, team, name, player_id)
);

ALTER TABLE IF EXISTS dwh.absent_hurt
    OWNER to postgres;