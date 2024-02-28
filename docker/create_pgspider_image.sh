#!/bin/sh

source ./env_rpm_optimize_image.conf
set -eE

if [[ ${PGSPIDER_RPM_ID} ]]; then
    PGSPIDER_RPM_ID_POSTFIX="-${PGSPIDER_RPM_ID}"
fi

# Push binary on repo
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then
    IMAGE_TAG=${PGSPIDER_RPM_ID}

    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${IMAGE_TAG} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg ACCESS_TOKEN=${ACCESS_TOKEN} \
        --build-arg DISTRIBUTION_TYPE=${RPM_DISTRIBUTION_TYPE} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_URL="https://tccloud2.toshiba.co.jp/swc/gitlab/api/v4/projects/${PGSPIDER_PROJECT_ID}/packages/generic/rpm_${RPM_DISTRIBUTION_TYPE}/${PGSPIDER_BASE_POSTGRESQL_VERSION}" \
        --build-arg PGSPIDER_RPM_ID=${PGSPIDER_RPM_ID_POSTFIX} \
        -f docker/Dockerfile .
else
    IMAGE_TAG=${PGSPIDER_RELEASE_VERSION}

    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg DISTRIBUTION_TYPE=${RPM_DISTRIBUTION_TYPE} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_URL="https://github.com/$OWNER_GITHUB/$PGSPIDER_PROJECT_GITHUB/releases/download/$PGSPIDER_RELEASE_VERSION" \
        -f docker/Dockerfile .
fi

docker push ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG}

# Clean
docker rmi ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG}
