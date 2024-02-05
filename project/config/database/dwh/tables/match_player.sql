-- Table: dwh.match_player

-- DROP TABLE IF EXISTS dwh.match_player;

CREATE TABLE IF NOT EXISTS dwh.match_player
(
    match_id text COLLATE pg_catalog."default",
	name text COLLATE pg_catalog."default",
    player_id_num smallint,
    team_id smallint,
    is_captain boolean,
    is_wicketkeeper boolean,
    is_registered boolean DEFAULT true,
    CONSTRAINT match_player_uk UNIQUE (match_id, player_id_num)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.match_player
    OWNER to postgres;