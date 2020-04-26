#!/bin/bash

# check if the role is specified
if [ -z "$ROLE" ]; then
        echo >&2 'Error:  You need to specify ROLE, values are master or slave'
        exit 1
fi

# check if the replication user is specified
if [ -z "$PG_REP_USER" ]; then
        echo >&2 'Error:  You need to specify PG_REP_USER'
        exit 1
fi

# check if the replication user password is specified
if [ -z "$PG_REP_PASSWORD" ]; then
        echo >&2 'Error:  You need to specify PG_REP_PASSWORD'
        exit 1
fi

# create replication user and also update hba conf to allow remote access of replication users
if [ "$ROLE" == "master" ]; then
	echo "master is setting up"
	echo "host replication all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
	set -e
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	CREATE USER $PG_REP_USER WITH REPLICATION ENCRYPTED PASSWORD '$PG_REP_PASSWORD';
	EOSQL
fi


# creates a pgpass file to save the password and perform the pg_basebackup of the master into slave data directory also automatically configures the slave
if [ "$ROLE" == "slave" ]; then
	echo "$PG_MASTER_HOST:$PG_MASTER_PORT:*:$PG_REP_USER:$PG_REP_PASSWORD" > "$HOME"/.pgpass
	chmod 0600 "$HOME"/.pgpass
	export PGPASSFILE="$HOME/.pgpass"
	rm -rf $PGDATA/*
	until pg_basebackup -h "${PG_MASTER_HOST}" -p "${PG_MASTER_PORT}" -D "${PGDATA}" -U "${PG_REP_USER}" -Fp -Xs -P -R
    		do
        	echo "Waiting for master to connect..."
        	sleep 1s
	done
	echo "host replication all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
fi

echo "Awesome ${ROLE} done!"

