SELECT
	match_id,
	
(
SELECT 
	p.id,
	p.identifier,
	p.key_cricinfo,
	p.unique_name,
	mp.match_id
FROM dwh.people p
LEFT JOIN dwh.player_info pi ON p.identifier = pi.identifier
JOIN dwh.match_player mp ON p.id = mp.player_id_num
JOIN dwh.espn_url url ON mp.match_id = url.match_id
WHERE pi.identifier IS NULL AND url.url_type = 'match'
) sub