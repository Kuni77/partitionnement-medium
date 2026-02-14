-- Génération de données de test pour le benchmark
-- 500 fleuves x 2 ans de mesures toutes les 10 minutes = ~52,6 millions de lignes
-- Exécution : docker exec -i river_monitoring_db psql -U river_user -d river_monitoring < generate-data.sql

TRUNCATE river_flow;

INSERT INTO river_flow (river_code, measured_at, flow_rate, received_at)
SELECT
    'RIVER_' || LPAD(r::text, 4, '0'),
    ts,
    100 + random() * 900,
    ts + interval '1 hour'
FROM
    generate_series(1, 500) AS r,
    generate_series(
        '2024-01-01'::timestamp,
        '2025-12-31 23:50:00'::timestamp,
        '10 minutes'::interval
    ) AS ts;

SELECT COUNT(*) AS total_rows FROM river_flow;
