#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
if [ -e .env ]; then
  printf '%s\n' '.env already exists; preserving it.'
  exit 0
fi
command -v openssl >/dev/null 2>&1 || { printf '%s\n' 'openssl is required.' >&2; exit 1; }
umask 077
{
  printf '%s\n' '# Local deployment credentials. Do not commit this file.'
  printf '%s\n' 'POSTGRES_USER=skinsync_admin'
  for name in POSTGRES_PASSWORD CATALOG_DB_PASSWORD QUIZ_DB_PASSWORD ORDER_DB_PASSWORD PAYMENT_DB_PASSWORD NOTIFICATION_DB_PASSWORD RABBITMQ_PASSWORD; do
    printf '%s=%s\n' "$name" "$(openssl rand -hex 16)"
  done
  printf '%s\n' 'RABBITMQ_USER=skinsync_app'
} > .env
printf '%s\n' 'Created local .env with generated credentials. Values were not printed.'
