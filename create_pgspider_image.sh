#!/bin/sh

source ./env_rpm_optimize_image.conf
set -eE

if [[ ${PGSPIDER_RPM_ID} ]]; then
    PGSPIDER_RPM_ID_POSTFIX="-${PGSPIDER_RPM_ID}"
fi

# Push binary on repo
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then 
    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${PGSPIDER_RPM_ID} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg ACCESS_TOKEN=${ACCESS_TOKEN} \
        --build-arg DISTRIBUTION_TYPE=${RPM_DISTRIBUTION_TYPE} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_ID=${PGSPIDER_RPM_ID_POSTFIX} .
else
    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${PGSPIDER_RPM_ID} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg DISTRIBUTION_TYPE=${RPM_DISTRIBUTION_TYPE} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_ID=${PGSPIDER_RPM_ID_POSTFIX} .
fi

docker push ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${PGSPIDER_RPM_ID}

# Clean
docker rmi ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${PGSPIDER_RPM_ID}
