PGS1_PORT=5433
PGS1_DB=pg1db
PGS2_PORT=5434
PGS2_DB=pg2db
DB_NAME=postgres

source $(pwd)/environment_variable.config

function clean_docker_img()
{
  if [ "$(docker ps -aq -f name=^/${1}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${1}$)" ]; then
        docker rm ${1}
    else
        docker rm $(docker stop ${1})
    fi
  fi
}

if [[ "--start" == $1 ]]
then
  cd ${PGSPIDER_HOME}/bin/
  #Start PGS1
  if ! [ -d "../${PGS1_DB}" ];
  then
    ./initdb ../${PGS1_DB}
    sed -i "s~#port = 4813.*~port = $PGS1_PORT~g" ../${PGS1_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PGS1_PORT postgres
  fi
  if ! ./pg_isready -p $PGS1_PORT
  then
    echo "Start PG1"
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
  fi
  #Start PGS2
  if ! [ -d "../${PGS2_DB}" ];
  then
    ./initdb ../${PGS2_DB}
    sed -i "s~#port = 4813.*~port = $PGS2_PORT~g" ../${PGS2_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg2
    sleep 2
    ./createdb -p $PGS2_PORT postgres
  fi
  if ! ./pg_isready -p $PGS2_PORT
  then
    echo "Start PG2"
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg2
    sleep 2
  fi
  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
    sleep 2
  fi
  # Start InfluxDB server
  if ! [[ $(systemctl status influxdb) == *"active (running)"* ]]
  then
    echo "Start InfluxDB Server"
    systemctl start influxdb
    sleep 2
  fi
  # Start GridDB server
  griddb_image=$GRIDDB_IMAGE
  griddb_container_name=griddb_svr
  clean_docker_img ${griddb_container_name}
  docker run -d --name ${griddb_container_name} -p 10001:10001 -e GRIDDB_NODE_NUM=1 ${griddb_image}
fi

cd $CURR_PATH

# Setup GridDB
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${GRIDDB_CLIENT}/bin
cp -a griddb_selectfunc.dat /tmp/
cp -a griddb_selectfunc1.dat /tmp/
cp -a griddb_selectfunc2.dat /tmp/
gcc griddb_init.c -o griddb_init -I${GRIDDB_CLIENT}/client/c/include -L${GRIDDB_CLIENT}/bin -lgridstore
# use 0 for multi test, use 1 for selectfunc test
./griddb_init 127.0.0.1:10001  dockerGridDB admin admin 1

# Setup SQLite
rm /tmp/pgtest.db
sqlite3 /tmp/pgtest.db < sqlite_selectfunc.dat

# Setup Mysql
mysql -uroot -pMysql_1234 < mysql_selectfunc.dat
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot -pMysql_1234 mysql

# Setup InfluxDB
influx -import -path=./influx_selectfunc.data -precision=ns

# Setup PGSpider1
$PGSPIDER_HOME/bin/psql -p $PGS1_PORT $DB_NAME < pgspider_selectfunc1.dat

# Setup PGSpider2
$PGSPIDER_HOME/bin/psql -p $PGS2_PORT $DB_NAME < pgspider_selectfunc2.dat
