# Zero-to-Prod Uptime & Observability Stack

This repository contains the end-to-end setup for the **Zero-to-Prod Uptime & Observability Stack** project.

## 📂 Folder Overview
- app/        → Flask web service (health & echo endpoints)
- nginx/      → Reverse proxy + TLS config
- db/         → PostgreSQL schema & replication scripts
- scripts/    → Helper scripts (healthcheck, alerts, log parser)
- systemd/    → Unit files & timers
- docs/       → Runbook, troubleshooting, demo scripts
- tests/      → Verification scripts and checks

