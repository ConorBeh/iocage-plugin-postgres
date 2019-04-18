#!/bin/sh

# Enable service

sysrc postgresql_enable="YES"

# Initialize database
service postgresql start
sleep 5
service postgresql initdb

# Allow access from specified subnet

# sed -i '' "s/127.0.0.1\/32/$SUBNET\/24/g" /var/db/postgres/data96/pg_hba.conf

# service postgresql restart
