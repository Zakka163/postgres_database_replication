#!/bin/bash
set -e

# Tunggu primary siap menerima koneksi
until pg_isready -h primary -p 5432 -U postgres; do
  echo "Waiting for primary to be ready..."
  sleep 2
done

# Jika data directory kosong, jalankan pg_basebackup
if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then
  echo "Starting base backup from primary..."
  pg_basebackup -h primary -D /var/lib/postgresql/data -U postgres -Fp -Xs -P -R
fi

# Jalankan PostgreSQL dengan config yang sudah di-mount
exec postgres -c config_file=/var/lib/postgresql/data/postgresql.conf
