CREATE TABLE river_flow (
    id            BIGSERIAL PRIMARY KEY,
    river_code    VARCHAR(50)      NOT NULL,
    measured_at   TIMESTAMP        NOT NULL,
    flow_rate     DOUBLE PRECISION NOT NULL,
    received_at   TIMESTAMP        NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_river_flow UNIQUE (river_code, measured_at)
);

CREATE INDEX idx_river_flow_river_code ON river_flow (river_code);
CREATE INDEX idx_river_flow_measured_at ON river_flow (measured_at);
