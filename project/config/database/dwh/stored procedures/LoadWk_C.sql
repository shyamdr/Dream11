-- PROCEDURE: dwh.loadregistry()

-- DROP PROCEDURE IF EXISTS dwh.loadwk_c();

CREATE OR REPLACE PROCEDURE dwh.loadwk_c(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN	
	UPDATE dwh.match_player mp
	SET is_wicketkeeper = true
	FROM (
		SELECT stg.match_id, p.id, p.identifier, p.unique_name
		FROM stg.match_wk_c stg
		JOIN dwh.people p ON (stg.wicket_keeper = p.key_cricinfo OR stg.wicket_keeper = p.key_cricinfo_2)
	) AS sub
	WHERE mp.match_id = sub.match_id AND mp.player_id_num = sub.id;

	UPDATE dwh.match_player mp
	SET is_captain = true
	FROM (
		SELECT stg.match_id, p.id, p.identifier, p.unique_name
		FROM stg.match_wk_c stg
		JOIN dwh.people p ON (stg.captain = p.key_cricinfo OR stg.captain = p.key_cricinfo_2)
	) AS sub
	WHERE mp.match_id = sub.match_id AND mp.player_id_num = sub.id;
	
	TRUNCATE stg.match_wk_c;

EXCEPTION
	WHEN OTHERS THEN ROLLBACK;

COMMIT;

END;
$BODY$;
ALTER PROCEDURE dwh.loadwk_c()
    OWNER TO postgres;