/*
select * from dwh.delivery where run_non_boundary limit 1000;

select * from dwh.delivery limit 100;

select * from dwh.wicket where match_id = '1375842'

select * from dwh.powerplay

select *, left(delivery_id::text, 1)=1 from dwh.wicket limit 1000;

*/


SELECT 
	sub.match_id,
	sub.inning,
	sub.team_id,
	--MIN(sub.min_delivery_id) AS min_delivery_id,
	--MIN(sub.min_non_striker_delivery_id) AS min_non_striker_delivery,
	CASE WHEN LEAST(MIN(sub.min_delivery_id),MIN(sub.min_non_striker_delivery_id)) IS NOT NULL THEN
		RANK() OVER (PARTITION BY sub.match_id, sub.inning ORDER BY LEAST(MIN(sub.min_delivery_id),MIN(sub.min_non_striker_delivery_id))) END AS bat_pos,
	--sub.bat_pos,
	p.unique_name AS batsman,
	SUM(sub.runs) AS runs,
	SUM(sub.balls_faced) AS balls_faced,
	SUM(sub."1''s") AS "1s",
	SUM(sub."2''s") AS "2s",
	SUM(sub."3''s") AS "3s",
	SUM(sub.other_rbw) AS other_rbw,
	SUM(sub."4''s") AS "4s",
	SUM(sub."6''s") AS "6s"
	--, sub.dismissal_kind
FROM
(
SELECT
	del.match_id,
	del.team_id,
	del.inning,
	mp.player_id_num,
	CASE WHEN (del.batter = mp.player_id_num) THEN MIN(del.delivery_id) END AS min_delivery_id,
	CASE WHEN (del.non_striker = mp.player_id_num) THEN (MIN(del.delivery_id)+0.1) END AS min_non_striker_delivery_id,
	CASE WHEN (del.batter = mp.player_id_num) AND (del.is_legal OR extra_noball IS NOT NULL) THEN COUNT(1) END AS balls_faced,
	CASE WHEN (del.batter = mp.player_id_num) THEN SUM(del.run_batter) END AS runs,
	CASE WHEN (del.batter = mp.player_id_num) AND del.is_legal AND run_batter = 0 THEN COUNT(1) END AS dots,
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 1 THEN COUNT(1) END AS "1''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 2 THEN COUNT(1) END AS "2''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 3 THEN COUNT(1) END AS "3''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary) AND del.run_batter > 3 THEN SUM(del.run_batter) END AS other_rbw,
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR NOT run_non_boundary) AND del.run_batter >=4 AND del.run_batter != 6 THEN COUNT(1) END AS "4''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR NOT run_non_boundary) AND del.run_batter = 6 THEN COUNT(1) END AS "6''s"
	--, CASE WHEN (del.batter = w.player_out OR del.non_striker = w.player_out) THEN w.kind END AS dismissal_kind
	
	/* ----- add in the top layer :- notout
	CASE 
		WHEN (del.batter = w.player_out OR del.non_striker = w.player_out) THEN TRUE
		WHEN (del.batter != w.player_out AND del.non_striker = w.player_out) THEN FALSE
		ELSE NULL
	END AS is_out
	*/
FROM dwh.match_player mp
LEFT JOIN dwh.delivery del ON mp.match_id = del.match_id AND mp.team_id = del.team_id --(del.batter = mp.player_id_num OR del.non_striker = mp.player_id_num)
--LEFT JOIN dwh.people p ON mp.player_id_num = p.id
LEFT JOIN dwh.wicket w ON del.match_id = w.match_id AND del.inning::text = LEFT(w.delivery_id::text,1) AND (del.batter = w.player_out OR del.non_striker = w.player_out)
WHERE del.match_id = '1386110' and del.inning = 2--'1375842'
GROUP BY 
	del.match_id,
	del.team_id,
	del.inning,
	mp.player_id_num,
	del.batter,
	del.non_striker,
	del.is_legal,
	del.extra_noball,
	run_non_boundary,
	run_batter,
	w.player_out,
	w.kind
) AS sub 
LEFT JOIN dwh.people p ON sub.player_id_num = p.id
--LEFT JOIN dwh.wicket w ON sub.match_id = w.match_id AND w.
GROUP BY
	sub.match_id,
	sub.inning,
	sub.team_id,
	p.unique_name
	--, sub.dismissal_kind
	--,sub.min_delivery_id
	--,sub.bat_pos
ORDER BY
	sub.match_id,
	sub.inning
	--, p.unique_name	
	
---------------------------------------------------------------------------------------------------------------------------------


/*
select * from dwh.delivery where run_non_boundary limit 1000;

select * from dwh.delivery limit 100;

select * from dwh.wicket where match_id = '1375842'

select * from dwh.powerplay

select *, left(delivery_id::text, 1)=1 from dwh.wicket limit 1000;

*/


SELECT 
	sub.match_id,
	sub.inning,
	sub.team_id,
	CASE WHEN LEAST(MIN(sub.min_delivery_id),MIN(sub.min_non_striker_delivery_id)) IS NOT NULL THEN
		RANK() OVER (PARTITION BY sub.match_id, sub.inning ORDER BY LEAST(MIN(sub.min_delivery_id),MIN(sub.min_non_striker_delivery_id))) END AS bat_pos,
	p.unique_name AS batsman,
	SUM(sub.runs) AS runs,
	SUM(sub.balls_faced) AS balls_faced,
	SUM(sub."1''s") AS "1s",
	SUM(sub."2''s") AS "2s",
	SUM(sub."3''s") AS "3s",
	SUM(sub.other_rbw) AS other_rbw,
	SUM(sub."4''s") AS "4s",
	SUM(sub."6''s") AS "6s",
	w.delivery_id as dismissal_delivery_id
FROM
(
SELECT
	del.match_id,
	del.team_id,
	del.inning,
	mp.player_id_num,
	CASE WHEN (del.batter = mp.player_id_num) THEN MIN(del.delivery_id) END AS min_delivery_id,
	CASE WHEN (del.non_striker = mp.player_id_num) THEN (MIN(del.delivery_id)+0.1) END AS min_non_striker_delivery_id,
	CASE WHEN (del.batter = mp.player_id_num) AND (del.is_legal OR extra_noball IS NOT NULL) THEN COUNT(1) END AS balls_faced,
	CASE WHEN (del.batter = mp.player_id_num) THEN SUM(del.run_batter) END AS runs,
	CASE WHEN (del.batter = mp.player_id_num) AND del.is_legal AND run_batter = 0 THEN COUNT(1) END AS dots,
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 1 THEN COUNT(1) END AS "1''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 2 THEN COUNT(1) END AS "2''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 3 THEN COUNT(1) END AS "3''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary) AND del.run_batter > 3 THEN SUM(del.run_batter) END AS other_rbw,
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR NOT run_non_boundary) AND del.run_batter >=4 AND del.run_batter != 6 THEN COUNT(1) END AS "4''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR NOT run_non_boundary) AND del.run_batter = 6 THEN COUNT(1) END AS "6''s"
FROM dwh.match_player mp
LEFT JOIN dwh.delivery del ON mp.match_id = del.match_id AND mp.team_id = del.team_id
--WHERE del.match_id = '1386110' and del.inning = 2 --'1375842'
GROUP BY 
	del.match_id,
	del.team_id,
	del.inning,
	mp.player_id_num,
	del.batter,
	del.non_striker,
	del.is_legal,
	del.extra_noball,
	run_non_boundary,
	run_batter
) AS sub 
LEFT JOIN dwh.people p ON sub.player_id_num = p.id
LEFT JOIN dwh.wicket w ON sub.match_id = w.match_id AND sub.inning::text = LEFT(w.delivery_id::text,1) AND sub.player_id_num = w.player_out
GROUP BY
	sub.match_id,
	sub.inning,
	sub.team_id,
	p.unique_name,
	w.delivery_id
ORDER BY
	sub.match_id,
	sub.inning	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
	sub.match_id,
	sub.inning,
	sub.team_id,
	CASE WHEN LEAST(MIN(sub.min_delivery_id),MIN(sub.min_non_striker_delivery_id)) IS NOT NULL THEN
		RANK() OVER (PARTITION BY sub.match_id, sub.inning ORDER BY LEAST(MIN(sub.min_delivery_id),MIN(sub.min_non_striker_delivery_id))) END AS bat_pos,
	p.unique_name AS batsman,
	p2.unique_name AS partner,
	SUM(sub.runs) AS runs,
	SUM(sub.balls_faced) AS balls_faced,
	SUM(sub.dots) AS dots,
	SUM(sub."1''s") AS "1s",
	SUM(sub."2''s") AS "2s",
	SUM(sub."3''s") AS "3s",
	SUM(sub.other_rbw) AS other_rbw,
	SUM(sub."4''s") AS "4s",
	SUM(sub."6''s") AS "6s",
	w.delivery_id as dismissal_delivery_id
	,sub.powerplay
FROM
(
SELECT
	del.match_id,
	del.team_id,
	del.inning,
	mp.player_id_num,
	CASE WHEN (del.batter = mp.player_id_num) THEN MIN(del.delivery_id) END AS min_delivery_id,
	CASE WHEN (del.non_striker = mp.player_id_num) THEN (MIN(del.delivery_id)+0.1) END AS min_non_striker_delivery_id,
	CASE WHEN (del.batter = mp.player_id_num) AND (del.is_legal OR extra_noball IS NOT NULL) THEN COUNT(1) END AS balls_faced,
	CASE WHEN (del.batter = mp.player_id_num) THEN SUM(del.run_batter) END AS runs,
	CASE WHEN (del.batter = mp.player_id_num) AND del.is_legal AND run_batter = 0 THEN COUNT(1) END AS dots,
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 1 THEN COUNT(1) END AS "1''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 2 THEN COUNT(1) END AS "2''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR run_non_boundary) AND del.run_batter = 3 THEN COUNT(1) END AS "3''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary) AND del.run_batter > 3 THEN SUM(del.run_batter) END AS other_rbw,
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR NOT run_non_boundary) AND del.run_batter >=4 AND del.run_batter != 6 THEN COUNT(1) END AS "4''s",
	CASE WHEN (del.batter = mp.player_id_num) AND (run_non_boundary IS NULL OR NOT run_non_boundary) AND del.run_batter = 6 THEN COUNT(1) END AS "6''s"
	,CASE WHEN (del.batter = mp.player_id_num) THEN pp.type END AS powerplay
	,CASE WHEN (del.batter = mp.player_id_num) THEN del.non_striker END AS partner
FROM dwh.match_player mp
LEFT JOIN dwh.delivery del ON mp.match_id = del.match_id AND mp.team_id = del.team_id
LEFT JOIN dwh.powerplay pp ON mp.match_id = pp.match_id AND del.team_id = pp.team_id AND del.legal_ball_num BETWEEN pp.from AND pp.to
--WHERE del.match_id = '1386110' and del.inning = 2 --'1375842'
WHERE del.match_id = '1386102' and del.inning = 2
GROUP BY 
	del.match_id,
	del.team_id,
	del.inning,
	mp.player_id_num,
	del.batter,
	del.non_striker,
	del.is_legal,
	del.extra_noball,
	run_non_boundary,
	run_batter
	,pp.type
) AS sub 
LEFT JOIN dwh.people p ON sub.player_id_num = p.id
LEFT JOIN dwh.people p2 ON sub.partner = p2.id
LEFT JOIN dwh.wicket w ON sub.match_id = w.match_id AND sub.inning::text = LEFT(w.delivery_id::text,1) AND sub.player_id_num = w.player_out
GROUP BY
	sub.match_id,
	sub.inning,
	sub.team_id,
	p.unique_name,
	p2.unique_name,
	w.delivery_id
	,sub.powerplay
ORDER BY
	sub.match_id,
	sub.inning