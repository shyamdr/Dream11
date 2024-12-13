CREATE OR REPLACE PROCEDURE dwh.loadscorecardallrounder(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN

WITH variables AS (
	SELECT
		20.0 AS wt_mt1, -- Best performance bat/bowl
		80.0 AS wt_mt2  -- Overall performance
)

, known_allrounders AS (
	SELECT id 
	FROM dwh.player_info
	WHERE role ILIKE '%allrounder%'
),

players AS (
	SELECT 
		id, 'ODI' AS match_type
	FROM known_allrounders
	UNION ALL
	SELECT 
		id, 'T20' AS match_type
	FROM known_allrounders
	UNION ALL
	SELECT 
		id, match_type
	FROM (
		SELECT 
			pi.id, 
			m.match_type,
			SUM(CASE WHEN sbowl.bowler IS NOT NULL THEN 1 ELSE 0 END) AS did_bowl,
			CASE 
				WHEN 
					COUNT(m.match_id) >= 10 AND 
					AVG(sbat.batting_order) <= 8 AND 
					SUM(CASE WHEN sbowl.bowler IS NOT NULL THEN 1 ELSE 0 END) >= COUNT(m.match_id)/3
				THEN TRUE ELSE FALSE
			END AS is_allrounder
		FROM dwh.player_info pi
		JOIN dwh.match_player mp ON pi.id = mp.player_id_num
		JOIN dwh.match m ON mp.match_id = m.match_id
		LEFT JOIN dwh.scorecard_batting sbat ON mp.match_id = sbat.match_id AND pi.id = sbat.batsman
		LEFT JOIN dwh.scorecard_bowling sbowl ON mp.match_id = sbowl.match_id AND pi.id = sbowl.bowler
		WHERE role NOT ILIKE '%allrounder%' AND	m.match_type NOT IN ('Test', 'MDM')
		group by 
			pi.id,
			m.match_type
	) sub
	WHERE is_allrounder
)

, matches AS (
	SELECT DISTINCT match_id FROM dwh.delivery
	WHERE NOT EXISTS (SELECT DISTINCT match_id from dwh.scorecard_allrounder)
)

, src AS (
SELECT
	COALESCE(a.match_type,b.match_type) AS match_type,
	COALESCE(a.match_id,b.match_id) AS match_id,
	COALESCE(a.team_id,b.team_id) AS team_id,
	COALESCE(a.batsman,b.bowler) AS player,
	COALESCE(a.batsman_name,b.bowler_name) AS player_name,
	a.total_score AS batting_score,
	b.total_score AS bowling_score,
-- 	(GREATEST(a.total_score,b.total_score) * v.wt_mt1/100.0) AS score1,
-- 	(GREATEST(COALESCE(a.total_score,50),0.5) * GREATEST(COALESCE(b.total_score,50),0.5)) * 40.0/10000.0 AS score2,
-- 	((COALESCE(a.total_score, 30.0) + COALESCE(b.total_score, 0)) * v.wt_mt2/200.0) AS score2,
	((GREATEST(a.total_score,b.total_score) * v.wt_mt1/100.0) + ((COALESCE(a.total_score, 30.0) + COALESCE(b.total_score, 0)) * v.wt_mt2/200.0)) AS total_score
FROM dwh.scorecard_bowling b
FULL OUTER JOIN dwh.scorecard_batting a ON CONCAT(a.match_id,a.batsman) = CONCAT(b.match_id, b.bowler)
INNER JOIN matches m ON m.match_id = COALESCE(a.match_id,b.match_id)
INNER JOIN players p ON p.id = COALESCE(a.batsman,b.bowler) AND p.match_type = COALESCE(a.match_type,b.match_type) 
INNER JOIN variables v ON 1=1
-- WHERE COALESCE(a.match_id,b.match_id) IN ('1254062')
)

INSERT INTO dwh.scorecard_allrounder
SELECT * FROM src
ON CONFLICT ON CONSTRAINT pk_scorecard_allrounder DO NOTHING;

EXCEPTION
	WHEN OTHERS THEN ROLLBACK;

COMMIT;

END;
$BODY$;
ALTER PROCEDURE dwh.loadscorecardallrounder()
    OWNER TO postgres;