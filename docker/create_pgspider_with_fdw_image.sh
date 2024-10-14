#!/bin/bash

# Save the list of existing environment variables before sourcing the env_rpmbuild.conf file.
before_vars=$(compgen -v)

source docker/env_rpm_optimize_image.conf

# Save the list of environment variables after sourcing the env_rpmbuild.conf file
after_vars=$(compgen -v)

# Find new variables created from configuration file
new_vars=$(comm -13 <(echo "$before_vars" | sort) <(echo "$after_vars" | sort))

# Export variables so that scripts or child processes can access them
for var in $new_vars; do
    export "$var"
done

set -eE

# validate parameters
chmod a+x docker/validate_parameters.sh
./docker/validate_parameters.sh location IMAGE_NAME_CUSTOMIZED DOCKERFILE_CUSTOMIZED BASEIMAGE proxy no_proxy

docker build -t ${IMAGE_NAME_CUSTOMIZED} \
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
        -f docker/${DOCKERFILE_CUSTOMIZED} .
