# Exports default environment variables for scripts/pg-start.sh and
# scripts/pg-stop.sh.
{
  PGHOST = "0.0.0.0";
  PGPORT = "5432";
  PGDATABASE = "hasura";
  PGUSER = "hasura";
  PGPASSWORD = "hasura";
  DATABASE_URL = "postgres://hasura:hasura@0.0.0.0:5432/hasura?sslmode=disable";
}
