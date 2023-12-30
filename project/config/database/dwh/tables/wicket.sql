CREATE TABLE dwh.wicket
(
    match_id text NOT NULL,
    delivery_id smallint NOT NULL,
    player_out smallint NOT NULL,
    kind text,
    fielder1 smallint,
    fielder2 smallint,
    fielder3 smallint,
    CONSTRAINT wicket_pk PRIMARY KEY (match_id, delivery_id, player_out)
);

ALTER TABLE IF EXISTS dwh.wicket
    OWNER to postgres;