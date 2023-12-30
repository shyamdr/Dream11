-- PROCEDURE: dwh.loaddelivery()

-- DROP PROCEDURE IF EXISTS dwh.loaddelivery();

CREATE OR REPLACE PROCEDURE dwh.loaddelivery(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
-------------- Add team details ----------------
MERGE INTO dwh.team t
USING (SELECT DISTINCT team FROM stg.delivery) s
ON s.team = t.name
WHEN NOT MATCHED THEN
INSERT(name) VALUES(team);

-------------- Create temp table ---------------
DROP TABLE IF EXISTS tmp_delivery;
CREATE TEMPORARY TABLE tmp_delivery AS
SELECT
	CAST(CONCAT(inning,ROW_NUMBER() OVER (PARTITION BY match_id,inning ORDER BY index)) AS integer) AS delivery_id,
	*
FROM stg.delivery;

----------- Flatten wickets details ------------
DELETE FROM dwh.wicket WHERE match_id IN (SELECT DISTINCT match_id FROM tmp_delivery);

INSERT INTO dwh.wicket
SELECT DISTINCT
	sub.match_id,
	sub.delivery_id,
	(SELECT player_id_num FROM dwh.match_player mp WHERE sub.match_id = mp.match_id AND mp.name = sub.player_out) AS player_out,
	sub.kind,
	(SELECT player_id_num FROM dwh.match_player mp WHERE sub.match_id = mp.match_id AND mp.name = f1.name) AS fielder1,
	(SELECT player_id_num FROM dwh.match_player mp WHERE sub.match_id = mp.match_id AND mp.name = f2.name) AS fielder2,
	(SELECT player_id_num FROM dwh.match_player mp WHERE sub.match_id = mp.match_id AND mp.name = f3.name) AS fielder3
FROM
(
SELECT
	d.match_id,
	d.delivery_id,
	wickets,
	x.player_out,
	x.kind,
	x.fielders,
	CASE WHEN 
		SPLIT_PART(REPLACE(CAST(x.fielders AS text), '}, {', '}]# [{'), '# ', 1) = '' THEN NULL
	ELSE
		CAST(SPLIT_PART(REPLACE(CAST(x.fielders AS text), '}, {', '}]# [{'), '# ', 1) AS JSON)
	END AS fielder1,	
	CASE WHEN 
		SPLIT_PART(REPLACE(CAST(x.fielders AS text), '}, {', '}]# [{'), '# ', 2) = '' THEN NULL
	ELSE
		CAST(SPLIT_PART(REPLACE(CAST(x.fielders AS text), '}, {', '}]# [{'), '# ', 2) AS JSON)
	END AS fielder2,	
	CASE WHEN 
		SPLIT_PART(REPLACE(CAST(x.fielders AS text), '}, {', '}]# [{'), '# ', 3) = '' THEN NULL
	ELSE
		CAST(SPLIT_PART(REPLACE(CAST(x.fielders AS text), '}, {', '}]# [{'), '# ', 3) AS JSON)
	END AS fielder3
FROM 
tmp_delivery d,
json_to_recordset(d.wickets) AS x(player_out text, kind text, fielders json)
LEFT JOIN LATERAL json_to_recordset(x.fielders) AS f(name text) ON TRUE
) sub
LEFT JOIN LATERAL json_to_recordset(sub.fielder1) AS f1(name text) ON TRUE
LEFT JOIN LATERAL json_to_recordset(sub.fielder2) AS f2(name text) ON TRUE
LEFT JOIN LATERAL json_to_recordset(sub.fielder3) AS f3(name text) ON TRUE;

--------- Flatten replacements details ---------
DELETE FROM dwh.replacement WHERE match_id IN (SELECT DISTINCT match_id FROM tmp_delivery);

INSERT INTO dwh.replacement
SELECT DISTINCT
	d.match_id,
	d.delivery_id,
	(SELECT team_id FROM dwh.team t WHERE d.team = t.name) AS team_id,
	'Match' AS replacement_type,
	(SELECT player_id_num FROM dwh.match_player mp WHERE d.match_id = mp.match_id AND mp.name = rep_match.in) AS "in",
	(SELECT player_id_num FROM dwh.match_player mp WHERE d.match_id = mp.match_id AND mp.name = rep_match.out) AS "out",
	rep_match.reason,
	NULL AS role
FROM tmp_delivery d,
json_to_recordset(d.replacements_match) AS rep_match("in" text, "out" text, team text, reason text)
UNION
SELECT 
	d.match_id,
	d.delivery_id,
	(SELECT team_id FROM dwh.team t WHERE d.team = t.name) AS team_id,
	'Role' AS replacement_type,
	(SELECT player_id_num FROM dwh.match_player mp WHERE d.match_id = mp.match_id AND mp.name = rep_role.in) AS "in",
	(SELECT player_id_num FROM dwh.match_player mp WHERE d.match_id = mp.match_id AND mp.name = rep_role.out) AS "out",
	rep_role.reason,
	rep_role.role
FROM tmp_delivery d,
json_to_recordset(d.replacements_role) AS rep_role("in" text, "out" text, reason text, role text);

------------ Flatten review details ------------
DELETE FROM dwh.review WHERE match_id IN (SELECT DISTINCT match_id FROM tmp_delivery);

INSERT INTO dwh.review
SELECT DISTINCT
	match_id,
	delivery_id,
	(SELECT team_id FROM dwh.team t WHERE d.review_by = t.name) AS team_id,
	(SELECT official_id_num FROM dwh.official off WHERE d.match_id = off.match_id AND d.review_umpire = off.name) AS review_umpire,
	(SELECT player_id_num FROM dwh.match_player mp WHERE d.match_id = mp.match_id AND d.review_batter = mp.name) AS review_batter,
	review_decision,
	review_type,
	CAST(review_umpires_call AS BOOLEAN)
FROM tmp_delivery d
WHERE review_by IS NOT NULL OR review_type IS NOT NULL;

------------- Add delivery details -------------
DELETE FROM dwh.delivery WHERE match_id IN (SELECT DISTINCT match_id FROM tmp_delivery);

INSERT INTO dwh.delivery
SELECT 
	match_id,
	delivery_id,
	inning,
	t.team_id,
	(SELECT player_id_num FROM dwh.match_player mp WHERE mp.match_id = del.match_id and mp.name = del.batter) as batter,
	(SELECT player_id_num FROM dwh.match_player mp WHERE mp.match_id = del.match_id and mp.name = del.bowler) as bowler,
	(SELECT player_id_num FROM dwh.match_player mp WHERE mp.match_id = del.match_id and mp.name = del.non_striker) as non_striker,
	del.runs_batter AS run_batter,
	del.runs_extras AS run_extra,
	del.runs_total AS run_total,
	del.runs_non_boundary AS run_non_boundary,
	del.overs_over AS over,
	CAST(ROW_NUMBER() OVER (PARTITION BY match_id,inning,team,overs_over ORDER BY index) AS smallint) AS ball_num,
	CASE WHEN (extras_wides IS NULL AND extras_noballs is NULL) THEN TRUE ELSE FALSE END AS is_legal,
	CAST(SUM(CASE WHEN (extras_wides IS NULL AND extras_noballs IS NULL) THEN 1 ELSE NULL END)
	OVER (PARTITION BY match_id, inning,team,overs_over ORDER BY index) AS smallint) AS legal_ball_num,
	CASE WHEN del.replacements_match IS NOT NULL OR del.replacements_role IS NOT NULL THEN TRUE ELSE NULL END AS is_replacement,
	del.extras_wides AS extra_wide,
	del.extras_legbyes AS extra_legbye,
	del.extras_noballs AS extra_noball,
	del.extras_byes AS extra_bye,
	del.extras_penalty AS extra_penalty,
	CASE WHEN del.review_by IS NOT NULL OR del.review_type IS NOT NULL THEN TRUE ELSE NULL END AS is_review,
	CASE WHEN del.wickets IS NOT NULL THEN TRUE ELSE NULL END AS is_wicket
FROM tmp_delivery del
LEFT JOIN dwh.team t ON del.team = t.name;

TRUNCATE TABLE tmp_delivery;
TRUNCATE TABLE stg.delivery;

EXCEPTION
	WHEN OTHERS THEN ROLLBACK;

COMMIT;

END;
$BODY$;
ALTER PROCEDURE dwh.loaddelivery()
    OWNER TO postgres;
