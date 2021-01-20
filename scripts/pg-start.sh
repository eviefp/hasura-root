#!/usr/bin/env sh
set -euo pipefail

pg_ctl -D ".pgdata" -w start || (echo pg_ctl failed; exit 1)
