---------------------------------------------------------------------
-- Creating a temporary table to maintain score sheet
DROP TABLE IF EXISTS scorecard;
CREATE TEMP TABLE scorecard (
	match_id INT DEFAULT 0,
	player_id SERIAL PRIMARY KEY,
	player VARCHAR(50),
	team VARCHAR(50),
	announced BOOL DEFAULT TRUE,
	runs INT DEFAULT 0,
	fours INT DEFAULT 0,
	sixes INT DEFAULT 0,
	balls_faced INT DEFAULT 0,
	strike_rate DECIMAL(5,2) DEFAULT 0,
	sr_bonus INT DEFAULT 0,
	runs_bonus INT DEFAULT 0,
	dismissed BOOL DEFAULT FALSE,
	duck BOOL DEFAULT FALSE,
	overs_bowled DECIMAL(2,1) DEFAULT 0,
	economy DECIMAL(5,2) DEFAULT 0,
	ec_bonus INT DEFAULT 0,
	maiden_over INT DEFAULT 0,
	wicket INT DEFAULT 0,
	lbw_bowled INT DEFAULT 0,
	wicket_bonus INT DEFAULT 0,
	catch INT DEFAULT 0,
	catch_bonus INT DEFAULT 0,
	stumping_runout INT DEFAULT 0,
	points DECIMAL(5,2)
);

---------------------------------------------------------------------
-- Updating match_id, player_id, player, team, announced

WITH id AS (SELECT 1)
INSERT INTO scorecard (match_id, player, team, announced)
SELECT (SELECT * FROM id) as match_id, 
player_list.*,
CASE WHEN player ILIKE '%(sub)%' THEN FALSE ELSE TRUE END AS announced
FROM 
(
	SELECT DISTINCT batsman AS player, batting_team as team FROM deliveries WHERE is_super_over = 0 and match_id = (SELECT * FROM id)
	UNION SELECT DISTINCT non_striker, batting_team FROM deliveries WHERE is_super_over = 0 and match_id = (SELECT * FROM id)
	UNION SELECT DISTINCT bowler, bowling_team FROM deliveries WHERE is_super_over = 0 and match_id = (SELECT * FROM id)
	UNION SELECT DISTINCT fielder, bowling_team FROM dismissals WHERE is_super_over = 0 and match_id = (SELECT * FROM id) and fielder != 'None'
) AS player_list;

---------------------------------------------------------------------
-- Updating Batting details - runs, fours, sixes, balls_faced, strike_rate, sr_bonus, runs_bonus.

WITH subquery AS (
	SELECT SQ1.player, 
	SUM(SQ1.runs) AS runs,
	SUM(SQ1.fours) AS fours,
	SUM(SQ1.sixes) AS sixes,
	SUM(SQ1.balls_faced) AS balls_faced,
	SUM(SQ1.runs)*100/SUM(SQ1.balls_faced) AS strike_rate,
	CASE
		WHEN SUM(SQ1.runs) BETWEEN 30 AND 49 THEN 4
		WHEN SUM(SQ1.runs) BETWEEN 50 AND 99 THEN 8
		WHEN SUM(SQ1.runs) >= 100 THEN 16
		ELSE 0
		END AS runs_bonus
	FROM
	(	
		SELECT player,
		SUM(deliveries.batsman_runs) AS runs,
		CASE WHEN deliveries.batsman_runs IN (4,5) THEN COUNT(*) END AS fours,
		CASE WHEN deliveries.batsman_runs IN (6,7) THEN COUNT(*) END AS sixes,
		CASE WHEN deliveries.wide_runs = 0 THEN COUNT(*) END AS balls_faced
		FROM scorecard
		LEFT JOIN deliveries on scorecard.player = deliveries.batsman AND scorecard.match_id = deliveries.match_id
		GROUP BY player,deliveries.batsman_runs, deliveries.wide_runs
	) AS SQ1
	INNER JOIN scorecard ON scorecard.player = SQ1.player
	GROUP BY 1
	ORDER BY player
)
UPDATE scorecard
SET runs = COALESCE(subquery.runs,0),
    fours = COALESCE(subquery.fours,0),
    sixes = COALESCE(subquery.sixes,0),
	balls_faced = COALESCE(subquery.balls_faced,0),
	strike_rate = COALESCE(subquery.strike_rate,0),
	sr_bonus = (CASE 
				WHEN subquery.balls_faced >= 10 AND subquery.strike_rate > 170 THEN 6
				WHEN subquery.balls_faced >= 10 AND subquery.strike_rate > 150 AND subquery.strike_rate < 170 THEN 4
				WHEN subquery.balls_faced >= 10 AND subquery.strike_rate BETWEEN 130 AND 150 THEN 2
				WHEN subquery.balls_faced >= 10 AND subquery.strike_rate BETWEEN 60 AND 70 THEN -2
				WHEN subquery.balls_faced >= 10 AND subquery.strike_rate >= 50 AND subquery.strike_rate < 60 THEN -4
				WHEN subquery.balls_faced >= 10 AND subquery.strike_rate < 50 THEN -6 
				ELSE 0 END),				
	runs_bonus = COALESCE(subquery.runs_bonus,0)
FROM subquery
WHERE scorecard.player = subquery.player;

---------------------------------------------------------------------
-- Update column dismissed.

WITH subquery AS (
	SELECT scorecard.player
	FROM scorecard
	INNER JOIN dismissals ON 
	scorecard.player = dismissals.player_dismissed AND scorecard.match_id = dismissals.match_id
)
UPDATE scorecard
SET dismissed = TRUE
FROM subquery
WHERE scorecard.player = subquery.player;

---------------------------------------------------------------------
-- Update column duck.

UPDATE scorecard 
SET duck = TRUE
WHERE dismissed = TRUE AND runs = 0;

---------------------------------------------------------------------
-- Find the overs_bowled, economy, ec_bonus.

WITH id AS (SELECT match_id from scorecard LIMIT 1),
subquery AS
(
	SELECT bowler as player, 
	CAST (SUM(balls) AS INT)/6 + (SUM(balls)%6)*0.1 AS overs_bowled,
	SUM(runs) AS runs,
	COALESCE(SUM(runs)*6/SUM(balls),0) as economy
	FROM
	(
		SELECT bowler,
		CASE WHEN wide_runs+noball_runs = 0 THEN COUNT(*) END AS balls,
		SUM(wide_runs + noball_runs + batsman_runs) as runs
		FROM deliveries
		WHERE match_id = (SELECT * FROM id)
		GROUP BY bowler, wide_runs, noball_runs
	) AS SQ1
	GROUP BY 1
)
UPDATE scorecard
SET overs_bowled = COALESCE(subquery.overs_bowled,0.0),
    economy = COALESCE(subquery.economy,0.0),
	ec_bonus = (CASE
				WHEN subquery.overs_bowled >= 2 AND subquery.economy < 5 THEN 6
				WHEN subquery.overs_bowled >= 2 AND subquery.economy >= 5 AND subquery.economy < 6 THEN 4
				WHEN subquery.overs_bowled >= 2 AND subquery.economy BETWEEN 6 AND 7 THEN 2
				WHEN subquery.overs_bowled >= 2 AND subquery.economy BETWEEN 10 AND 11 THEN -2
				WHEN subquery.overs_bowled >= 2 AND subquery.economy > 11 AND subquery.economy <= 12 THEN -4
				WHEN subquery.overs_bowled >= 2 AND subquery.economy > 12 THEN -6 
				ELSE 0 END)				
FROM subquery
WHERE scorecard.player = subquery.player;

---------------------------------------------------------------------
-- Update maiden_over

WITH id AS (SELECT match_id FROM scorecard LIMIT 1),
subquery AS
(
	SELECT SQ1.bowler AS player, SUM(SQ1.maiden_over) AS maiden_over
	FROM
	(
		SELECT bowler,
		CASE SUM(batsman_runs + wide_runs + noball_runs)
			WHEN 0 THEN 1 ELSE 0 END AS maiden_over 
		FROM deliveries
		WHERE match_id = (SELECT * FROM id)
		GROUP BY 1,over
		ORDER BY 1
	) AS SQ1
	GROUP BY 1
)
UPDATE scorecard
SET maiden_over = COALESCE(subquery.maiden_over,0)
FROM subquery
WHERE scorecard.player = subquery.player;

---------------------------------------------------------------------
-- Update wicket, lbw_bowled, wicket_bonus

WITH id AS (SELECT match_id FROM scorecard LIMIT 1),
subquery AS
(
	SELECT bowler,
	SUM(wicket) AS wicket,
	COUNT(lbw_bowled) AS lbw_bowled,
	CASE
		WHEN SUM(wicket) >= 5 THEN 16
		WHEN SUM(wicket) >= 4 THEN 8
		WHEN SUM(wicket) >= 3 THEN 4 ELSE 0
	END AS wicket_bonus
	FROM
	(
		SELECT bowler,
		CASE
			WHEN dismissal_kind IN ('caught','bowled','lbw','caught and bowled','stumped','hit wicket') THEN COUNT(*) END AS wicket,
		CASE
			WHEN dismissal_kind IN ('lbw','bowled') THEN COUNT(*) END AS lbw_bowled
		FROM dismissals
		WHERE match_id = (SELECT * FROM id)
		GROUP BY 1, dismissal_kind
	) AS SQ1
	GROUP BY 1
)
UPDATE scorecard
SET wicket = COALESCE(subquery.wicket,0),
	lbw_bowled = COALESCE(subquery.lbw_bowled,0),
	wicket_bonus = COALESCE(subquery.wicket_bonus,0)
FROM subquery
WHERE scorecard.player = subquery.bowler;

---------------------------------------------------------------------
-- Update catch, catch_bonus, stumping_runout

WITH id AS (SELECT match_id from scorecard LIMIT 1),
subquery AS
(
	SELECT fielder,
	SUM(catch) AS catch,
	CASE WHEN SUM(catch) >= 3 THEN 4 ELSE 0 END AS catch_bonus,
	SUM(stumping_runout) AS stumping_runout
	FROM
	(
		SELECT fielder,
		CASE
			WHEN dismissal_kind IN ('caught') THEN COUNT(*) END AS catch,
		CASE
			WHEN dismissal_kind IN ('stumped','run out') THEN COUNT(*) END AS stumping_runout
		FROM dismissals
		WHERE match_id = (SELECT * FROM id)
		GROUP BY 1, dismissal_kind
	) AS SQ1
	GROUP BY 1
)
UPDATE scorecard
SET catch = COALESCE(subquery.catch,0),
	catch_bonus = COALESCE(subquery.catch_bonus,0),
	stumping_runout = COALESCE(subquery.stumping_runout,0)
FROM subquery
WHERE scorecard.player = subquery.fielder;

UPDATE scorecard
SET points = COALESCE(
(CAST(announced AS INT)+1)*2 +
runs +
fours +
sixes*2 +
sr_bonus +
runs_bonus +
CAST(duck AS INT)*(-2) +
ec_bonus +
maiden_over*12 +
wicket*25 +
lbw_bowled*8 +
wicket_bonus +
catch*8 +
catch_bonus +
stumping_runout*12,
0);

select * from scorecard
ORDER BY player_id;