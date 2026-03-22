# Zero-to-Prod Uptime & Observability Stack

> A production-grade uptime and observability stack built on Linux — featuring TLS reverse proxy, Flask microservice, partitioned PostgreSQL with streaming replication, systemd automation, SLO-driven alerting, and a full log intelligence pipeline.

---

## Architecture Overview

<img width="1078" height="863" alt="image" src="https://github.com/user-attachments/assets/b401af32-3495-4e80-8b31-f4d43c7e4738" />


> **Single VM setup:** All roles (Host A Edge, Host B App + DB Primary, Host C DB Replica) run on one box with configs split by role — as permitted by the project spec.

**SLOs:**
- Availability ≥ 99.5+% on `/health` (rolling 15 min)
- p95 latency < 300ms at edge (rolling 15 min)
- DB replica streaming with minimal lag
- Daily backup present

---

## Repository Structure

```
zero-to-prod/
├── app/                    # Flask application
│   ├── app.py              # main Flask application
│   └── requirements.txt
├── nginx/                  # Nginx config + TLS
│   ├── site.conf
│   └── certs/
├── db/                     # PostgreSQL setup scripts
│   ├── init.sql
│   └── partitions.sql
├── scripts/                # Python automation scripts
│   ├── healthcheck.py
│   ├── parse_logs.py
│   └── alert.sh
├── systemd/                # systemd service and timer units
│   ├── app.service
│   └── healthcheck.timer
├── docs/                   # Runbook and troubleshooting guides
│   ├── runbook.md
│   └── troubleshooting.md
├── tests/                  # Test scripts
│   └── test_endpoints.py
└── README.md
```

---

## Prerequisites

- 1 Linux VM (Ubuntu 22.04 recommended) — all roles (Edge, App, DB Primary, DB Replica) run on a single box with configs split by role
- Python 3.10+
- Nginx
- PostgreSQL 15+
- systemd
- `curl`, `openssl`, `nmap`, `tcpdump` utilities

---

## Setup Guide

### Step 1 — Repo & Hosts

```bash
# Clone the repo
git clone https://github.com/<your-username>/zero-to-prod-uptime-and-observability-stack.git
cd zero-to-prod-uptime-and-observability-stack

# All roles run on a single VM — set role-based hostnames via /etc/hosts
echo "127.0.0.1 edge" | sudo tee -a /etc/hosts
echo "127.0.0.1 appdb" | sudo tee -a /etc/hosts
echo "127.0.0.1 replica" | sudo tee -a /etc/hosts

# Verify network and open ports
ss -tulnp
```

---

### Step 2 — Flask App (Host B)

```bash
cd app/
pip install -r requirements.txt

# Install as a systemd service
sudo cp ../systemd/app.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable app
sudo systemctl start app

# Verify
systemctl status app
curl http://localhost:5000/health
```

**Endpoints:**
- `GET /health` → `{ "status": "ok", "ts": "<timestamp>", "host": "<hostname>" }`
- `POST /echo` → echoes request body/params

**Test restart-on-failure:**
```bash
sudo systemctl kill -s SIGKILL app
sleep 3
systemctl status app   # should show active (running) again
```

---

### Step 3 — Edge Proxy & TLS (Host A)

```bash
sudo apt install nginx -y

# Generate self-signed cert
sudo mkdir -p /etc/nginx/certs
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/certs/edge.key \
  -out /etc/nginx/certs/edge.crt \
  -subj "/CN=edge"

# Deploy Nginx config
sudo cp nginx/site.conf /etc/nginx/sites-available/default
sudo nginx -t && sudo systemctl reload nginx

# Verify TLS
openssl s_client -connect edge:443 -servername edge
curl -skI https://edge/app/health
```

---

### Step 4 — PostgreSQL Primary (Host B)

```bash
sudo apt install postgresql-15 -y

# Run setup scripts
sudo -u postgres psql -f db/init.sql
sudo -u postgres psql -f db/partitions.sql

# Verify
sudo -u postgres psql -c "\dt hc_metrics*"
```

The `hc_metrics` table is partitioned by month with an index on `(ts, route)`:

```sql
CREATE TABLE hc_metrics (
  ts          TIMESTAMPTZ NOT NULL,
  host        TEXT,
  route       TEXT,
  status      INT,
  latency_ms  FLOAT
) PARTITION BY RANGE (ts);
```

---

### Step 5 — Health Checks & Metrics (Host B)

```bash
# Install systemd timer
sudo cp systemd/healthcheck.timer /etc/systemd/system/
sudo cp systemd/healthcheck.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now healthcheck.timer

# Verify runs
journalctl -u healthcheck -f
```

`healthcheck.py` hits `https://edge/app/health`, measures latency, and inserts into `hc_metrics`. If the DB write fails, it queues JSON to `/var/tmp/hc-queue/` for later replay.

---

### Step 6 — Streaming Replication (Host C)

```bash
# On Host B (primary): configure WAL and replication slot
# On Host C (replica): configure recovery and start

# Verify replication
sudo -u postgres psql -c "SELECT pg_is_in_recovery();"         # Host C → true
sudo -u postgres psql -c "SELECT * FROM pg_stat_replication;"  # Host B → shows replica

# Verify firewall (from Host C)
nmap -p 5432 appdb   # should show open
nmap -p 80 appdb     # should show filtered
```

---

### Step 7 — Log Intelligence (Host A)

```bash
python3 scripts/parse_logs.py

# Output: reports/YYYY-MM-DD.csv
# Columns: route, availability_pct, p95_ms, 4xx_count, 5xx_count, top_ips
```

Supports `.gz` rotated logs. Optional: writes daily summary back to `hc_metrics` on Host B.

---

### Step 8 — Alerts & Backups

```bash
# Set your webhook URL
export WEBHOOK_URL="https://hooks.slack.com/services/..."

# Run alert check manually
bash scripts/alert.sh

# Check alert log
tail -f /var/log/incidents.log
```

Alert triggers if the last 15 minutes show:
- Availability < 99.5%, **or**
- p95 latency > 300ms

Nightly automation (via cron/systemd timer):
- `VACUUM ANALYZE hc_metrics`
- Backup to `/backup/YYYY/MM/DD/`
- Log rotation via `logrotate`

---

### Step 9 — Troubleshooting Drills

```bash
# Drill 1: Replica "connection refused"
# → Check firewall, pg_hba.conf, and replication slot

# Drill 2: TLS SNI mismatch
openssl s_client -connect edge:443 -servername wrongname
# → Fix server_name in Nginx config

# Drill 3: Inject latency and watch alert fire
sudo tc qdisc add dev eth0 root netem delay 400ms
# Wait for alert → check /var/log/incidents.log
sudo tc qdisc del dev eth0 root
```

Full fixes documented in [docs/troubleshooting.md](docs/troubleshooting.md).

---

### Step 10 — Hardening

```bash
# Verify security headers
curl -skI https://edge/app/health | grep -E "Strict|X-Content"
```

Headers applied in Nginx config:
- `Strict-Transport-Security: max-age=31536000`
- `X-Content-Type-Options: nosniff`
- Minimal TLS ciphers (TLSv1.2+)

---

## Demo Script (3–4 min)

```bash
# 1. Show TLS is live
curl -skI https://edge/app/health
openssl s_client -connect edge:443 -servername edge 2>/dev/null | head -10

# 2. Show Flask service
systemctl status app

# 3. Show healthcheck timer firing
journalctl -u healthcheck --since "5 minutes ago"

# 4. Show metrics in DB
sudo -u postgres psql mydb -c \
  "SELECT route, AVG(latency_ms), COUNT(*) FROM hc_metrics GROUP BY route;"

# 5. Show replica is in recovery
sudo -u postgres psql -h replica mydb -c "SELECT pg_is_in_recovery();"

# 6. Show replication lag
sudo -u postgres psql mydb -c "SELECT * FROM pg_stat_replication;"

# 7. Run log parser
python3 scripts/parse_logs.py
cat reports/$(date +%Y-%m-%d).csv

# 8. Inject latency, watch alert fire
sudo tc qdisc add dev eth0 root netem delay 400ms
sleep 60
cat /var/log/incidents.log
sudo tc qdisc del dev eth0 root
```

---

## Skills Demonstrated

| Area | What's covered |
|---|---|
| Python & scripting | healthcheck.py, parse_logs.py, regex log parsing, incident reports |
| Linux & systemd | services, timers, logrotate, process monitoring, restart-on-failure |
| Files & dirs | rotated logs, replay queues, daily backups |
| Regex & patterns | Nginx log parsing → p95, error rates, top IPs |
| Networking | DNS, curl/wget/openssl, ports, tcpdump, firewall rules |
| Security | TLS, HSTS, minimal ciphers, least-privilege DB user |
| DB admin | partitioning, streaming replication, VACUUM, backup/restore |
| Troubleshooting | DB down, TLS mismatch, induced latency drills |

## Conclusion

This project goes beyond running a simple application — it focuses on how real systems behave in production.
It demonstrates how traffic is handled through a reverse proxy, how services are monitored continuously, and how failures are detected and acted upon using alerts. By implementing replication, automated health checks, log analysis, and recovery workflows, this setup reflects practical DevOps principles such as reliability, observability, and fault tolerance.
Building this helped me understand not just how to deploy services, but how to operate, monitor, and troubleshoot them in a production-like environment.
