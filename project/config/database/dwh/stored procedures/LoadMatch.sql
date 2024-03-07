CREATE OR REPLACE PROCEDURE dwh.LoadScorecardBatting()
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
-- add event details
MERGE INTO dwh.event t
USING (SELECT DISTINCT event_name, season FROM stg.match) AS s
ON s.event_name = t.name AND s.season = t.season
WHEN NOT MATCHED THEN
	INSERT (name, season)
	VALUES (s.event_name, s.season);
	
-- add ground details
MERGE INTO dwh.ground t
USING (SELECT DISTINCT city, venue FROM stg.match) AS s
ON s.venue = t.venue
WHEN NOT MATCHED THEN
	INSERT (city, venue)
	VALUES (s.city, s.venue)
WHEN MATCHED AND COALESCE(s.city,t.city) != t.city
THEN UPDATE SET city = s.city;

-- Truncate and load match record details
DELETE FROM dwh.match WHERE match_id IN (SELECT DISTINCT match_id FROM stg.match);

INSERT INTO dwh.match 
SELECT DISTINCT
	stg.match_id,
	balls_per_over,
	e.event_id,
	stg.season,
	gender,
	g.ground_id,
	start_date,
	end_date,
	match_type,
	stg.match_type_number as match_type_num,
	overs,
	player_of_match,
	team_type,
	team_host as host,
	team_visitor as visitor,
	toss_winner,
	toss_decision,
	toss_uncontested,
	outcome_winner,
	outcome_by_wickets,
	outcome_by_runs,
	outcome_by_innings,
	outcome_result,
	outcome_eliminator,
	outcome_method,
	outcome_bowl_out,
	event_match_number,
	event_group,
	event_stage,
	p.identifier as player_of_match_id
FROM stg.match stg
LEFT JOIN dwh.event e ON stg.event_name = e.name AND stg.season = e.season
LEFT JOIN dwh.ground g ON stg.city = g.city AND stg.venue = g.venue
LEFT JOIN dwh.people p ON stg.player_of_match = p.unique_name;

TRUNCATE TABLE stg.match;

EXCEPTION
	WHEN OTHERS THEN ROLLBACK;

COMMIT;

END;
$BODY$;
ALTER PROCEDURE dwh.loadmatch()
    OWNER TO postgres;
