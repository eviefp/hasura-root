# Exports default environment variables for scripts/pg-start.sh and
# scripts/pg-stop.sh.
{
  PGHOST = "localhost";
  PGPORT = "5432";
  PGDATABASE = "hasura";
  PGUSER = "hasura";
  PGPASSWORD = "hasura";
  DATABASE_URL = "postgres://hasura:hasura@127.0.0.1:5432/hasura?sslmode=disable";
}
