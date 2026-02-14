-- ============================================================
-- Migration V2 : Partitionnement de river_flow par mois
-- La table garde le même nom => aucun changement côté Java
-- ============================================================

-- 1. Renommer la table existante
ALTER TABLE river_flow RENAME TO river_flow_old;

-- 1b. Supprimer les contraintes et index de l'ancienne table
-- (PostgreSQL conserve les noms des contraintes lors d'un RENAME)
ALTER TABLE river_flow_old DROP CONSTRAINT uq_river_flow;
ALTER TABLE river_flow_old DROP CONSTRAINT river_flow_pkey;
DROP INDEX IF EXISTS idx_river_flow_river_code;
DROP INDEX IF EXISTS idx_river_flow_measured_at;

-- 2. Créer la nouvelle table partitionnée par RANGE sur measured_at
-- Note : dans une table partitionnée PostgreSQL, la clé de partition
-- doit faire partie de toute contrainte UNIQUE ou PRIMARY KEY.
-- On ne peut donc pas avoir un BIGSERIAL PRIMARY KEY seul.
CREATE TABLE river_flow (
    id            BIGSERIAL,
    river_code    VARCHAR(50)      NOT NULL,
    measured_at   TIMESTAMP        NOT NULL,
    flow_rate     DOUBLE PRECISION NOT NULL,
    received_at   TIMESTAMP        NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, measured_at),
    CONSTRAINT uq_river_flow UNIQUE (river_code, measured_at)
) PARTITION BY RANGE (measured_at);

-- 3. Créer les partitions mensuelles (2024-01 à 2026-12)

-- 2024
CREATE TABLE river_flow_2024_01 PARTITION OF river_flow FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE river_flow_2024_02 PARTITION OF river_flow FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
CREATE TABLE river_flow_2024_03 PARTITION OF river_flow FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
CREATE TABLE river_flow_2024_04 PARTITION OF river_flow FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
CREATE TABLE river_flow_2024_05 PARTITION OF river_flow FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
CREATE TABLE river_flow_2024_06 PARTITION OF river_flow FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
CREATE TABLE river_flow_2024_07 PARTITION OF river_flow FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
CREATE TABLE river_flow_2024_08 PARTITION OF river_flow FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
CREATE TABLE river_flow_2024_09 PARTITION OF river_flow FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
CREATE TABLE river_flow_2024_10 PARTITION OF river_flow FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
CREATE TABLE river_flow_2024_11 PARTITION OF river_flow FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
CREATE TABLE river_flow_2024_12 PARTITION OF river_flow FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');

-- 2025
CREATE TABLE river_flow_2025_01 PARTITION OF river_flow FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE river_flow_2025_02 PARTITION OF river_flow FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE river_flow_2025_03 PARTITION OF river_flow FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE river_flow_2025_04 PARTITION OF river_flow FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE river_flow_2025_05 PARTITION OF river_flow FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE river_flow_2025_06 PARTITION OF river_flow FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');
CREATE TABLE river_flow_2025_07 PARTITION OF river_flow FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');
CREATE TABLE river_flow_2025_08 PARTITION OF river_flow FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');
CREATE TABLE river_flow_2025_09 PARTITION OF river_flow FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
CREATE TABLE river_flow_2025_10 PARTITION OF river_flow FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
CREATE TABLE river_flow_2025_11 PARTITION OF river_flow FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
CREATE TABLE river_flow_2025_12 PARTITION OF river_flow FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

-- 2026
CREATE TABLE river_flow_2026_01 PARTITION OF river_flow FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE river_flow_2026_02 PARTITION OF river_flow FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE river_flow_2026_03 PARTITION OF river_flow FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE river_flow_2026_04 PARTITION OF river_flow FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE river_flow_2026_05 PARTITION OF river_flow FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE river_flow_2026_06 PARTITION OF river_flow FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');
CREATE TABLE river_flow_2026_07 PARTITION OF river_flow FOR VALUES FROM ('2026-07-01') TO ('2026-08-01');
CREATE TABLE river_flow_2026_08 PARTITION OF river_flow FOR VALUES FROM ('2026-08-01') TO ('2026-09-01');
CREATE TABLE river_flow_2026_09 PARTITION OF river_flow FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');
CREATE TABLE river_flow_2026_10 PARTITION OF river_flow FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');
CREATE TABLE river_flow_2026_11 PARTITION OF river_flow FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');
CREATE TABLE river_flow_2026_12 PARTITION OF river_flow FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

-- 4. Migrer les données de l'ancienne table vers la nouvelle (partitionnée)
INSERT INTO river_flow (id, river_code, measured_at, flow_rate, received_at)
SELECT id, river_code, measured_at, flow_rate, received_at
FROM river_flow_old;

-- 5. Mettre à jour la séquence pour reprendre après le dernier ID migré
SELECT setval('river_flow_id_seq', (SELECT COALESCE(MAX(id), 1) FROM river_flow));

-- 6. Supprimer l'ancienne table
DROP TABLE river_flow_old;

-- 7. Recréer les index (les index de la table parent sont hérités par les partitions)
CREATE INDEX idx_river_flow_river_code ON river_flow (river_code);
CREATE INDEX idx_river_flow_measured_at ON river_flow (measured_at);
