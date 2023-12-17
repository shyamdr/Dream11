CREATE OR REPLACE PROCEDURE dwh.LoadPowerplay(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN

-- Truncate and load powerplay record details
DELETE FROM dwh.powerplay WHERE match_id IN (SELECT DISTINCT match_id FROM stg.powerplay);

INSERT INTO dwh.powerplay(match_id,match_type,team,type,"from","to") 
SELECT 
	PP.match_id,
	M.match_type,
	PP.team,
	CASE
		WHEN PP.from = 0.1 THEN 'MBP'
		WHEN PP.type = 'batting' THEN 'BP'
		WHEN M.match_type ilike '%OD%' OR M.match_type IS NULL
			AND PP.type != 'fielding' 
			AND PP.from BETWEEN 34 AND 50 
			AND PP.to BETWEEN 34 AND 50 THEN 'BP'
		WHEN PP.type = 'fielding' THEN 'FP'
		WHEN M.match_type ilike '%OD%' THEN 'FP'
		ELSE 'FP'
	END AS type,
	PP.from,
	PP.to
FROM stg.powerplay PP
LEFT JOIN dwh.match M ON PP.match_id = M.match_id;

TRUNCATE TABLE stg.powerplay;

EXCEPTION
	WHEN OTHERS THEN ROLLBACK;

COMMIT;

END;
$BODY$;
ALTER PROCEDURE dwh.loadpowerplay()
    OWNER TO postgres;