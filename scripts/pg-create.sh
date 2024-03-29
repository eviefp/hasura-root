#!/usr/bin/env sh
set -euo pipefail

pg_pid=""

LOCAL_PGHOST=$PGHOST
LOCAL_PGPORT=$PGPORT
LOCAL_PGDATABASE=$PGDATABASE
LOCAL_PGUSER=$PGUSER
LOCAL_PGPASSWORD=$PGPASSWORD

unset PGUSER PGPASSWORD

initdb -D .pgdata

echo "unix_socket_directories = '$(mktemp -d)'" >> .pgdata/postgresql.conf
echo "listen_addresses = '*'" >> .pgdata/postgresql.conf
echo "log_statement = all" >> .pgdata/postgresql.conf
echo "host all all 0.0.0.0/0 trust" >> .pgdata/pg_hba.conf

# TODO: port
pg_ctl -D ".pgdata" -w start || (echo pg_ctl failed; exit 1)

until psql postgres -c "SELECT 1" > /dev/null 2>&1 ; do
   echo waiting for pg
   sleep 0.5
done

psql postgres -w -c "CREATE DATABASE $LOCAL_PGDATABASE"
psql postgres -w -c "CREATE ROLE $LOCAL_PGUSER WITH LOGIN PASSWORD '$LOCAL_PGPASSWORD'"
psql postgres -w -c "ALTER USER $LOCAL_PGUSER WITH SUPERUSER"
psql postgres -w -c "GRANT ALL PRIVILEGES ON DATABASE $LOCAL_PGDATABASE TO $LOCAL_PGUSER"
