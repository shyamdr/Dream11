CREATE TABLE dwh.name
(
    identifier text,
    name text,
    CONSTRAINT identifier_fk FOREIGN KEY (identifier)
        REFERENCES dwh.people (identifier) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID
);

ALTER TABLE IF EXISTS dwh.name
    OWNER to postgres;