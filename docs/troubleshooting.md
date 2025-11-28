## Drill 1: Replica Connection Failed (pg_hba.conf)

Symptom:
psql shows "no pg_hba.conf entry for host"

Root Cause:
Replica rejected client IP due to missing pg_hba rule

Fix:
Added host entry and restarted postgres

Verification:
psql remote connection successful

## Drill 2: TLS SNI Mismatch

Symptom:
Wrong certificate / TLS warning

Root Cause:
Client sent incorrect SNI value

Fix:
Re-sent request with correct hostname

Verification:
TLS handshake successful with localhost

## Drill 3: Artificial Latency Injection

Symptom:
High response time

Root Cause:
Network delay injected using tc

Fix:
Removed qdisc rule

Verification:
Latency returned to normal

