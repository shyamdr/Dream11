CREATE OR REPLACE PROCEDURE dwh.LoadInning(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
-- Truncate and load inning details
DELETE FROM dwh.inning WHERE match_id IN (SELECT DISTINCT match_id FROM stg.inning);

INSERT INTO dwh.inning 
SELECT 
	CONCAT(match_id, '_',
ROW_NUMBER() OVER (PARTITION BY match_id ORDER BY match_id, target_runs DESC)
	) AS inning_id,*
FROM stg.inning;

TRUNCATE TABLE stg.inning;

EXCEPTION
	WHEN OTHERS THEN ROLLBACK;

COMMIT;

END;
$BODY$;
ALTER PROCEDURE dwh.LoadInning()
    OWNER TO postgres;