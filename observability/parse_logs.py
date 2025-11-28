#!/usr/bin/env python3
import re, statistics, csv
from collections import Counter

LOG_FILE = "/var/log/nginx/access.log"
OUTPUT = "reports/task7_report.csv"

pattern = re.compile(
    r'(?P<ip>\d+\.\d+\.\d+\.\d+).*?"'
    r'(?P<method>\w+) (?P<route>/\S*).*?"\s'
    r'(?P<status>\d{3}).*?\s'
    r'(?P<rt>\d+\.\d+)'
)

statuses = []
latencies = []
ips = []

with open(LOG_FILE) as f:
    for line in f:
        match = pattern.search(line)
        if match:
            status = int(match['status'])
            rt = float(match['rt'])

            statuses.append(status)
            latencies.append(rt)
            ips.append(match['ip'])

total = len(statuses)
errors = len([s for s in statuses if s >= 400])
errors_4xx = len([s for s in statuses if 400 <= s < 500])
errors_5xx = len([s for s in statuses if s >= 500])

availability = round(((total - errors) / total) * 100, 2) if total else 0
p95 = round(statistics.quantiles(latencies, n=100)[94], 4) if latencies else 0
top_ips = Counter(ips).most_common(5)

with open(OUTPUT, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["Metric", "Value"])
    writer.writerow(["Total Requests", total])
    writer.writerow(["Availability %", availability])
    writer.writerow(["p95 Latency (s)", p95])
    writer.writerow(["4xx Errors", errors_4xx])
    writer.writerow(["5xx Errors", errors_5xx])
    writer.writerow(["Top IPs", top_ips])

print(" Report created:", OUTPUT)

