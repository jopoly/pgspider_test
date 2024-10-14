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
./docker/validate_parameters.sh location IMAGE_NAME DOCKERFILE PGSPIDER_RPM_ID proxy no_proxy PACKAGE_RELEASE_VERSION PGSPIDER_BASE_POSTGRESQL_VERSION PGSPIDER_RELEASE_VERSION PASSWORD_PGS_CONTAINER_REGISTRY USERNAME_PGS_CONTAINER_REGISTRY PGSPIDER_CONTAINER_REGISTRY

if [[ ${PGSPIDER_RPM_ID} ]]; then
    PGSPIDER_RPM_ID_POSTFIX="-${PGSPIDER_RPM_ID}"
    IMAGE_TAG=${PGSPIDER_RPM_ID}
else
    IMAGE_TAG="latest"
fi

# Push binary on repo
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then
    ./docker/validate_parameters.sh PROJECT_PATH API_V4_URL PGSPIDER_PROJECT_ID
    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${IMAGE_TAG} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg ACCESS_TOKEN=${ACCESS_TOKEN} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PACKAGE_RELEASE_VERSION=${PACKAGE_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_URL="${API_V4_URL}/projects/${PGSPIDER_PROJECT_ID}/packages/generic/rpm_rhel8/${PGSPIDER_BASE_POSTGRESQL_VERSION}" \
        --build-arg PGSPIDER_RPM_ID=${PGSPIDER_RPM_ID_POSTFIX} \
        -f docker/${DOCKERFILE} .
    
    docker push ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
    docker rmi ${PGSPIDER_CONTAINER_REGISTRY}/${PROJECT_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
else
    ./docker/validate_parameters.sh OWNER_GITHUB PGSPIDER_PROJECT_GITHUB
    IMAGE_TAG=${PGSPIDER_RELEASE_VERSION}
    echo $PASSWORD_PGS_CONTAINER_REGISTRY | docker login --username ${USERNAME_PGS_CONTAINER_REGISTRY} --password-stdin ${PGSPIDER_CONTAINER_REGISTRY}
    docker build -t ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG} \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PACKAGE_RELEASE_VERSION=${PACKAGE_RELEASE_VERSION} \
        --build-arg PGSPIDER_RPM_URL="https://github.com/$OWNER_GITHUB/$PGSPIDER_PROJECT_GITHUB/releases/download/$PGSPIDER_RELEASE_VERSION" \
        -f docker/${DOCKERFILE} .

    docker push ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG}
    docker rmi ${PGSPIDER_CONTAINER_REGISTRY}/${OWNER_GITHUB}/${IMAGE_NAME}:${IMAGE_TAG}
fi
