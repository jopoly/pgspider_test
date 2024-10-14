mkdir -p ../pgspider-build
./configure --without-readline --without-zlib --prefix $PWD/../pgspider-build
make -j 4
make install
cd contrib
git clone https://github.com/pgspider/influxdb_fdw.git
cd influxdb_fdw
PATH=$PWD/../pgspider-build/bin:$PATH make
PATH=$PWD/../pgspider-build/bin:$PATH make install
cd ../postgres_fdw
PATH=$PWD/../pgspider-build/bin:$PATH make
PATH=$PWD/../pgspider-build/bin:$PATH make install

