CREATE TABLE dwh.team
(
    team_id serial NOT NULL,
    name text NOT NULL,
    CONSTRAINT team_pk PRIMARY KEY (team_id),
	CONSTRAINT team_uk UNIQUE (name)
);

ALTER TABLE IF EXISTS dwh.team
    OWNER to postgres;
	
INSERT INTO dwh.team(name)
VALUES
('India'),
('England'),
('Australia'),
('New Zealand'),
('South Africa'),
('West Indies'),
('Afghanistan'),
('Pakistan'),
('Bangladesh'),
('Netherland');