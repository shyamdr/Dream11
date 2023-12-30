-- View: dwh.vw_registry

-- DROP VIEW dwh.vw_registry;

CREATE OR REPLACE VIEW dwh.vw_registry
 AS
 WITH all_names AS (
         SELECT DISTINCT people.name,
            people.identifier
           FROM dwh.people
        UNION
         SELECT DISTINCT people.unique_name,
            people.identifier
           FROM dwh.people
        UNION
         SELECT DISTINCT name.name,
            name.identifier
           FROM dwh.name
        )
 SELECT p.id,
    all_names.identifier,
    all_names.name
   FROM all_names
     JOIN dwh.people p ON all_names.identifier = p.identifier;

ALTER TABLE dwh.vw_registry
    OWNER TO postgres;