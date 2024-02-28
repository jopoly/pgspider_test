#!/bin/sh

source ./env_rpm_optimize_image.conf
set -eE

docker build -t ${IMAGE_NAME_OPTIMIZED} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg baseimage=${BASEIMAGE} \
        --build-arg SQLITE_URL_PACKAGE=${SQLITE_URL_PACKAGE} \
        --build-arg SQLITE_ACCESS_TOKEN=${SQLITE_ACCESS_TOKEN} \
        --build-arg SQLITE_FDW_URL_PACKAGE=${SQLITE_FDW_URL_PACKAGE} \
        --build-arg SQLITE_FDW_ACCESS_TOKEN=${SQLITE_FDW_ACCESS_TOKEN} \
        --build-arg INFLUXDB_CXX_URL_PACKAGE=${INFLUXDB_CXX_URL_PACKAGE} \
        --build-arg INFLUXDB_CXX_ACCESS_TOKEN=${INFLUXDB_CXX_ACCESS_TOKEN} \
        --build-arg INFLUXDB_FDW_URL_PACKAGE=${INFLUXDB_FDW_URL_PACKAGE} \
        --build-arg INFLUXDB_FDW_ACCESS_TOKEN=${INFLUXDB_FDW_ACCESS_TOKEN} \
        --build-arg AWS_S3_CPP_URL_PACKAGE=${AWS_S3_CPP_URL_PACKAGE} \
        --build-arg AWS_S3_CPP_ACCESS_TOKEN=${AWS_S3_CPP_ACCESS_TOKEN} \
        --build-arg ARROW_URL_PACKAGE=${ARROW_URL_PACKAGE} \
        --build-arg ARROW_ACCESS_TOKEN=${ARROW_ACCESS_TOKEN} \
        --build-arg PARQUET_S3_FDW_URL_PACKAGE=${PARQUET_S3_FDW_URL_PACKAGE} \
        --build-arg PARQUET_S3_FDW_ACCESS_TOKEN=${PARQUET_S3_FDW_ACCESS_TOKEN} \
        -f docker/${DOCKERFILE_OPTIMIZED} .
