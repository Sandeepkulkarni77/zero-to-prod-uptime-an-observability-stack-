

CREATE DATABASE uptime;

CREATE USER app_user WITH PASSWORD 'user@123';

CREATE TABLE hc_metrics (
    ts TIMESTAMPTZ,
    host TEXT,
    route TEXT,
    status INT,
    latency_ms INT
) PARTITION BY RANGE (ts);

CREATE TABLE hc_metrics_2025_11 PARTITION OF hc_metrics
FOR VALUES FROM ('2025-11-01 00:00:00') TO ('2025-12-01 00:00:00');

GRANT SELECT, INSERT ON hc_metrics TO app_user;
GRANT INSERT ON hc_metrics_2025_11 TO app_user;

CREATE TABLE hc_metrics_2025_12 PARTITION OF hc_metrics
FOR VALUES FROM ('2025-12-01 00:00:00') TO ('2026-01-01 00:00:00');


