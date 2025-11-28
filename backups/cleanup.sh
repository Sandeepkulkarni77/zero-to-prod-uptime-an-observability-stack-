#!/bin/bash
find /backup -type f -name "*.sql" -mtime +7 -delete

