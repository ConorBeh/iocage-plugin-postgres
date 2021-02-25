#!/bin/sh

# Enable Postgres service
sysrc -f /etc/rc.conf postgresql_enable="YES"

# Start the service
service postgresql initdb 2>/dev/null
sleep 5
service postgresql start 2>/dev/null
sleep 5

# Assign variables
USER="pguser"
DB="postgresdb"
SUPERUSER="pgsuper"

# Save the config values
echo "$DB" > /root/dbname
echo "$USER" > /root/dbuser
echo "$SUPERUSER" > /root/dbsuperuser
export LC_ALL=C
# Normal user
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > /root/dbpassword
PASS=`cat /root/dbpassword`

# Superuser
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > /root/superdbpassword
SUPERPASS=`cat /root/superdbpassword`

# create user
psql -d template1 -U postgres -c "CREATE USER ${USER} CREATEDB SUPERUSER;" 2>/dev/null

# Create production database & grant all privileges on database
psql -d template1 -U postgres -c "CREATE DATABASE ${DB} OWNER ${USER};" 2>/dev/null

# Set a password on the postgres account
psql -d template1 -U postgres -c "ALTER USER ${USER} WITH PASSWORD '${PASS}';" 2>/dev/null

# Create new superuser user
psql -d template1 -U postgres -c "CREATE ROLE ${SUPERUSER} LOGIN SUPERUSER PASSWORD '${SUPERPASS}';

# Connect as superuser and enable pg_trgm extension
psql -U postgres -d ${DB} -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;" 2>/dev/null

# Fix permission for postgres 
echo "listen_addresses = '*'" >> /var/db/postgres/data11/postgresql.conf 2>/dev/null
echo "host  all  all 0.0.0.0/0 md5" >> /var/db/postgres/data11/pg_hba.conf 2>/dev/null

# Restart postgresql after config change
service postgresql restart 2>/dev/null
sleep 5

# Save database information
echo "Host: localhost or 127.0.0.1" > /root/PLUGIN_INFO
echo "Database Type: PostgresSQL" >> /root/PLUGIN_INFO
echo "Database Name: $DB" >> /root/PLUGIN_INFO
echo "Database User: $USER" >> /root/PLUGIN_INFO
echo "Database User Password: $PASS" >> /root/PLUGIN_INFO
echo "Databaser Super Username: $SUPERUSER" >> /root/PLUGIN_INFO
echo "Database Super User: $SUPERPASS" >> /root/PLUGIN_INFO

# Thank you Asigra plugin for your service on this hack
echo "Figure out our Network IP"
#Very Dirty Hack to get the ip for dhcp, the problem is that IOCAGE_PLUGIN_IP doesent work on DCHP clients
#cat /var/db/dhclient.leases* | grep fixed-address | uniq | cut -d " " -f4 | cut -d ";" -f1 > /root/dhcpip
#netstat -nr | grep lo0 | awk '{print $1}' | uniq | cut -d " " -f4 | cut -d ";" -f1 > /root/dhcpip
netstat -nr | grep lo0 | grep -v '::' | grep -v '127.0.0.1' | awk '{print $1}' | head -n 1 > /root/dhcpip
#netstat -nr | grep lo0 | awk '{print $1}' > /root/dhcpip 
#sed -i.bak '2,$d' /root/dhcpip 
IP=`cat /root/dhcpip`
#rm /root/dhcpip.bak

# Show user database details 
echo "-------------------------------------------------------"
echo "DATABASE INFORMATION"
echo "-------------------------------------------------------"
echo "Host: ${IP}" 
echo "Database Type: PostgreSQL" 
echo "First Database Name: $DB" 
echo "Database User: $USER" 
echo "Database User Password: $PASS" 
echo "Databaser Super Username: $SUPERUSER"
echo "Database Super User Password: $SUPERPASS"
echo "If you are using Davinci Resolve, you need to use the superuser"
echo "These passwords are randomly generated"
echo "To review this information again click Post Install Notes"
