Demo Script — Short Version
1) TLS + Reverse Proxy
curl -kI https://edge/app/health


Expected output:

HTTP/1.1 200 OK
Strict-Transport-Security: max-age=31536000; includeSubDomains


Reverse proxy + HTTPS is working, HSTS is enforced.

2) App Service (systemd)
systemctl status app.service


Expected:

active (running)


Crash test:

sudo pkill -f app.py
sleep 3
systemctl status app.service


Service auto-recovers.

3) Database Replication

On replica:

psql -c "SELECT pg_is_in_recovery();"


Expected:

t


Lag check:

psql -c "SELECT now() - pg_last_xact_replay_timestamp();"


Replica is in sync.

4) Health Metrics Check
psql -d hc -c "SELECT count(*) FROM hc_metrics;"


Health checks are writing data every minute.

5) Log Intelligence
python3 scripts/parse_logs.py


Expected:

reports/task7_health_report.csv created


Logs parsed for:

availability

p95 latency

error rate

top IPs

6) Alert System (High Latency Test)
sudo tc qdisc add dev eth0 root netem delay 400ms


Alert fires within 15 minutes.

Restore:

sudo tc qdisc del dev eth0 root

7) Backup Proof
ls /backup/$(date +%Y/%m/%d)


Nightly backups present.

Final line: End-to-end stack built with TLS, service management, database replication, observability, alerting, and recovery — all running like a real production setup
