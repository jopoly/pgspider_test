#!/bin/sh

# fix global environment
PGSPIDER_USER=pgspider
PGSPIDER_PASSWORD=pgspider
DEFAULT_PGSPIDER_DB=pgspider
PGS_BIN=/usr/pgsql-${PGSPIDER_BASE_POSTGRESQL_VERSION}/bin
PGSDATA=/var/lib/postgresql/data
RPMDATA=/home/pgspider/rpmdata
ENABLE_FLAG=1

set -eE

# handle when error
docker_handle_error() {
    local exit_code=$?
    local numline=$1
    local funcname=$2
	local allparam=${@:3}

    echo "Error: Non-zero exit code ($exit_code) at line $numline in function $funcname($allparam)"
}

# set trap to catch error
trap 'docker_handle_error $LINENO $FUNCNAME $@' ERR

# used to create initial database directory and RPM package directory
docker_create_db_directories() {
	mkdir -p "$PGSDATA"
	# ignore failure since there are cases where we can't chmod (and PostgreSQL might fail later anyhow - it's picky about permissions of this directory)
	chmod 00700 "$PGSDATA" || :

	# ignore failure since it will be fine when using the image provided directory; see also https://github.com/docker-library/postgres/pull/289
	mkdir -p /var/run/postgresql || :
	chmod 03775 /var/run/postgresql || :

	mkdir -p "$RPMDATA"
	chmod 00700 "$RPMDATA" || :
}

# setup listening to all address
docker_pg_setup_hba_conf() {
	echo "host all all all trust" >> "${PGSDATA}/pg_hba.conf"
	echo "listen_addresses = '*'" >> "${PGSDATA}/postgresql.conf"
}

# default database is named "pgspider"
docker_create_pg_databases() {
	if [[ "$PGSPIDER_DB" != "NULL" ]]; then
		${PGS_BIN}/createdb $PGSPIDER_DB
	else
		${PGS_BIN}/createdb $DEFAULT_PGSPIDER_DB
	fi
}

# launch psql client 
docker_launch_psql() {
	if [[ "$PGSPIDER_DB" != "NULL" ]]; then
		${PGS_BIN}/psql $PGSPIDER_DB
	else
		${PGS_BIN}/psql $DEFAULT_PGSPIDER_DB
	fi
}

_main() {
	# create database directory
    docker_create_db_directories

    # initialize empty PGSDATA directory with new database via 'initdb'
    ${PGS_BIN}/initdb ${PGSDATA} > /dev/null 2>&1

	# start server with PGSDATA
    ${PGS_BIN}/pg_ctl -D ${PGSDATA} -l ${PGSDATA}/logfile start

	# setup pg_hba and pg_conf
	docker_pg_setup_hba_conf

	# restart server with PGSDATA
    ${PGS_BIN}/pg_ctl -D ${PGSDATA} -l ${PGSDATA}/logfile restart > /dev/null 2>&1

	# create pgspider database
	docker_create_pg_databases
	# After container was created, 
	# 	set ENABLE_PSQL_CLIENT to show psql window.
	# 	set DETACH_MODE to running in detach mode.
	# If not set, the container with stop after running immediately.
	if [[ "$3" == [eE][nN][aA][bB][lL][eE][_][pP][sS][qQ][lL][_][cC][lL][iI][eE][nN][tT] ]]; then
		docker_launch_psql
	elif [[ "$1" == [dD][eE][tT][aA][cC][hH][_][mM][oO][dD][eE] ]]; then
		# this is the trick to help the container run after running docker
		tail -f > dev/null
	fi
}

_main "$@"
