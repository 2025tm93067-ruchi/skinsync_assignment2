#!/bin/sh
set -eu
# This script runs only when the PostgreSQL data volume is first initialized.
for service in catalog quiz order payment notification; do
  case "$service" in
    catalog) password="$CATALOG_DB_PASSWORD" ;;
    quiz) password="$QUIZ_DB_PASSWORD" ;;
    order) password="$ORDER_DB_PASSWORD" ;;
    payment) password="$PAYMENT_DB_PASSWORD" ;;
    notification) password="$NOTIFICATION_DB_PASSWORD" ;;
  esac
  psql --set=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres \
    --set=service_user="${service}_user" --set=service_database="${service}_db" \
    --set=service_password="$password" <<'SQL'
CREATE ROLE :"service_user" LOGIN PASSWORD :'service_password';
CREATE DATABASE :"service_database" OWNER :"service_user";
REVOKE ALL ON DATABASE :"service_database" FROM PUBLIC;
SQL
done
