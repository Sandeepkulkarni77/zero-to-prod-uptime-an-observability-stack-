#!/bin/bash

REPORT="../observability/reports/task7_report.csv"
ALERT_LOG="/var/log/incidents.log"

AVAIL=$(awk -F, '/Availability/{print $2}' $REPORT)
P95=$(awk -F, '/p95/{print $2}' $REPORT)

NOW=$(date "+%Y-%m-%d %H:%M:%S")

if (( $(echo "$AVAIL < 99.5" | bc -l) )) || (( $(echo "$P95 > 0.300" | bc -l) )); then
    MSG="ALERT [$NOW] Availability=$AVAIL p95=$P95"
    echo "$MSG" | tee -a $ALERT_LOG
fi

