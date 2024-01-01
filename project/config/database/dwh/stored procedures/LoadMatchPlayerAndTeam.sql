-- PROCEDURE: dwh.LoadMatchPlayerAndTeam()

-- DROP PROCEDURE IF EXISTS dwh.LoadMatchPlayerAndTeam();

CREATE OR REPLACE PROCEDURE dwh.LoadMatchPlayerAndTeam(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
-- Add team details
MERGE INTO dwh.team t
USING (SELECT DISTINCT team FROM stg.match_player) mp
ON mp.team = t.name
WHEN NOT MATCHED THEN
INSERT(name) VALUES(team);

-- Add match_player details
MERGE INTO dwh.match_player tgt
USING 
(SELECT
	match_id,
	p.id AS player_id_num,
	t.team_id AS team_id,
	CASE WHEN p.identifier IS NOT NULL THEN TRUE ELSE FALSE END AS is_registered
FROM stg.match_player mp
LEFT JOIN dwh.people p ON mp.player_id = p.identifier
LEFT JOIN dwh.team t ON mp.team = t.name
) src
ON src.match_id = tgt.match_id AND src.player_id_num = tgt.player_id_num
WHEN MATCHED AND (tgt.is_registered != src.is_registered OR src.is_registered IS NULL)
THEN UPDATE
SET is_registered = src.is_registered
WHEN NOT MATCHED THEN INSERT(match_id, player_id_num, team_id, is_registered)
VALUES(src.match_id, src.player_id_num, src.team_id, src.is_registered);

TRUNCATE TABLE stg.match_player;

EXCEPTION
	WHEN OTHERS THEN ROLLBACK;

COMMIT;

END;
$BODY$;
ALTER PROCEDURE dwh.LoadMatchPlayerAndTeam()
    OWNER TO postgres;