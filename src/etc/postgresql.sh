#!/bin/sh
#
# Configure PostgreSQL.
# ------------------------------------------------------------------------------

if dpkg --get-selections | grep -q '^postgresql.*\si'
  then echo 'Configuring PostgreSQL'
  vpsql=$(psql --version | cut -d' ' -f3 | cut -d. -f1)
  sed -i "s/#listen_addresses = .*/listen_addresses = '*'/" /etc/postgresql/"$vpsql"/main/postgresql.conf
  sed -i 's/ peer$/ trust/g' /etc/postgresql/"$vpsql"/main/pg_hba.conf && service postgresql restart
  psql -U postgres -c '\du' | grep -q root || psql -U postgres -c "create role root with superuser password 'vagrant' login" >/dev/null
  service postgresql restart
fi
