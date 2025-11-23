ivboxuser@sandeep-vm1:~/zero-to-prod-uptime-an-observability-stack-/db$ sudo -u postgres psql 
[sudo] password for vboxuser: 
could not change directory to "/home/vboxuser/zero-to-prod-uptime-an-observability-stack-/db": Permission denied
psql (14.19 (Ubuntu 14.19-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# CREATE DATABASE uptime; 
CREATE DATABASE
                       ^
postgres=# CREATE USER app_user WITH PASSWORD 'user@123'; 
CREATE ROLE
postgres=# CREATE TABLE hc_metrics (
    ts TIMESTAMPTZ,
    host TEXT,
    route TEXT,
    status INT,
    latency_ms INT
) PARTITION BY RANGE (ts);
CREATE TABLE                        ^
postgres=# CREATE TABLE hc_metrics_2025_11 PARTITION OF hc_metrics
FOR VALUES FROM ('2025-11-01 00:00:00') TO ('2025-12-01 00:00:00');
CREATE TABLE
postgres=# GRANT SELECT, INSERT ON hc_metrics TO app_user;
GRANT
postgres=# GRANT INSERT ON hc_metrics_2025_11 TO app_user;
GRANT
postgres=# CREATE TABLE hc_metrics_2025_12 PARTITION OF hc_metrics
FOR VALUES FROM ('2025-12-01 00:00:00') TO ('2026-01-01 00:00:00');
CREATE TABLE
postgres=# GRANT INSERT ON hc_metrics_2025_12 TO app_user;
GRANT
postgres=# CREATE INDEX idx_hc_metrics_ts_route ON hc_metrics (ts, route);
CREATE INDEX

