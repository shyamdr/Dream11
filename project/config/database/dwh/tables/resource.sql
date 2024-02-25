CREATE TABLE IF NOT EXISTS dwh.resource
(
    type text COLLATE pg_catalog."default",
    over numeric(4,1),
    ball smallint,
    wicket_lost smallint,
    resource numeric(4,1)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS dwh.resource
    OWNER to postgres;