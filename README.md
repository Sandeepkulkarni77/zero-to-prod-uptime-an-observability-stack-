# Zero-to-Prod Uptime & Observability Stack

This project is a small production-like setup that I built to practice real DevOps concepts instead of just running sample apps.

The goal was to understand how services behave in production: how traffic comes in, how failures happen, how monitoring works, and how recovery is handled.

# How this setup works

Traffic enters through Nginx running with HTTPS.  
Requests are forwarded to a Flask application running as a systemd service.  
Health data is stored in PostgreSQL, and a replica is configured for failover and reporting.

[ Client ]
    |
    v
[ Nginx + TLS ]  (Host A)
    |
    v
[ Flask App ]    (Host B)
    |
    v
[ PostgreSQL Primary ] ───> [ PostgreSQL Replica ] (Host C)

# Folder structure
- app/ → Flask application  
- nginx/ → Nginx reverse proxy and TLS config  
- db/ → SQL schema and database setup  
- observability/ → log intelligence and reports  
- scripts/ → health check and helper scripts  
- alerts/ → alerting logic  
- backups/ → DB backup scripts and jobs  
- systemd/ → service files and timers  
- docs/ → runbook, troubleshooting, demo script  
- tests/ → testing and validation file

# What I implemented
- HTTPS with Nginx
- Flask app as systemd service
- PostgreSQL primary and replica
- Health monitoring script
- Log analysis using regex
- Alerts on latency and downtime
- Automated backups
- Manual failure testing and recovery

# Targets used
Availability: 99.5+%  
Latency: under 300ms  
Alert window: 15 minutes  
Backups: daily

# Demo
1- https op: <img width="963" height="218" alt="https" src="https://github.com/user-attachments/assets/e4d3ec98-093a-460b-9fb2-ffefc2ac7bba" />

2- nginx.service: <img width="1229" height="495" alt="nginx" src="https://github.com/user-attachments/assets/16030f0e-9378-49ca-96f2-3f6718b2f612" />

3- postgres.service: <img width="1313" height="251" alt="postgres" src="https://github.com/user-attachments/assets/a1b58ae8-2812-4142-9349-2540cc46d79e" />

# Note
This project helped me understand:
- how services fail
- how alerts work
- how logs help debugging
- how recovery actually happens
