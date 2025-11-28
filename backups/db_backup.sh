#!/bin/bash
set -e

DATE=$(date +%Y/%m/%d)
BACKUP_DIR="/backup/$DATE"
DB="postgres"     # change if you use a different DB
USER="postgres"   # change if needed
HOST="localhost"

mkdir -p "$BACKUP_DIR"

FILE="$BACKUP_DIR/db_$(date +%H%M%S).sql"

pg_dump -h "$HOST" -U "$USER" "$DB" > "$FILE"

echo "Backup created: $FILE"

