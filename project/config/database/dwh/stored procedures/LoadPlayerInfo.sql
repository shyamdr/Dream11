CREATE OR REPLACE PROCEDURE dwh.LoadPlayerInfo()
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN

MERGE INTO dwh.player_info t
USING (
SELECT
	p.id,
	p.identifier,
	s.key_cricinfo,
	s.name,
	s.full_name,
	s.dob,
	TRIM(s.birth_place) AS birth_place,
	CASE
		WHEN POSITION('Left' in s.batting_style) > 0 THEN 'Left'
		WHEN POSITION('Right' in s.batting_style) > 0 THEN 'Right'
		ELSE NULL
	END AS batting_hand,
	s.bowling_hand,
	s.bowling_style,
	s.fielding_pos,
	s.playing_role AS role,
	s.url	
FROM stg.player_info s
JOIN dwh.people p ON s.key_cricinfo = p.key_cricinfo
) AS s
ON s.id = t.id
WHEN NOT MATCHED THEN
	INSERT (id, identifier, key_cricinfo, name, full_name, dob, birth_place, batting_hand, bowling_hand, bowling_style, fielding_pos, role, url)
	VALUES (s.id, s.identifier, s.key_cricinfo, s.name, s.full_name, s.dob, s.birth_place, s.batting_hand, s.bowling_hand, s.bowling_style, s.fielding_pos, s.role, s.url)
WHEN MATCHED THEN UPDATE SET 
	identifier = s.identifier, 
	key_cricinfo = s.key_cricinfo, 
	name = s.name, 
	full_name = s.full_name, 
	dob = s.dob, 
	birth_place = s.birth_place, 
	batting_hand = s.batting_hand, 
	bowling_hand = s.bowling_hand, 
	bowling_style = s.bowling_style, 
	fielding_pos = s.fielding_pos, 
	role = s.role, 
	url = s.url;

EXCEPTION
	WHEN OTHERS THEN ROLLBACK;

COMMIT;

END;
$BODY$;
ALTER PROCEDURE dwh.LoadPlayerInfo()
    OWNER TO postgres;