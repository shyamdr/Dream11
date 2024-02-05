CREATE TABLE dwh.weather
(
    match_id text NOT NULL,
    ground_id smallint,
    "time" timestamp with time zone,
    temperature numeric(4, 2),
    relative_humidity_perc smallint,
    dew_point numeric(4, 2),
    precipitation smallint,
    rain smallint,
    cloud_cover_perc smallint,
    surface_pressure numeric(6, 2),
    wind_speed numeric(4, 2),
    soil_temperature numeric(4, 2),
    soil_moisture numeric(4, 2)
);

ALTER TABLE IF EXISTS dwh.weather
    OWNER to postgres;