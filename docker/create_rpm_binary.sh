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
./docker/validate_parameters.sh location IMAGE_NAME_RPM DOCKERFILE_RPM ARTIFACT_DIR proxy no_proxy PACKAGE_RELEASE_VERSION PGSPIDER_BASE_POSTGRESQL_VERSION PGSPIDER_RELEASE_VERSION

# download postgres documentation
if [[ ! -f postgresql-${PGSPIDER_BASE_POSTGRESQL_VERSION}-A4.pdf ]]; then
    wget https://www.postgresql.org/files/documentation/pdf/${PGSPIDER_BASE_POSTGRESQL_VERSION}/postgresql-${PGSPIDER_BASE_POSTGRESQL_VERSION}-A4.pdf
fi

# Create Docker image for creating RPM file of PGSpider.
docker build -t $IMAGE_NAME_RPM \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg PACKAGE_RELEASE_VERSION=${PACKAGE_RELEASE_VERSION} \
        -f docker/$DOCKERFILE_RPM .

# Get RPM file from container image.
rm -rf $ARTIFACT_DIR || true
mkdir -p $ARTIFACT_DIR
docker run --rm -v $(pwd)/$ARTIFACT_DIR:/tmp \
                -u "$(id -u $USER):$(id -g $USER)" \
                -e LOCAL_UID=$(id -u $USER) \
                -e LOCAL_GID=$(id -g $USER) $IMAGE_NAME_RPM /bin/sh \
                -c "cp /home/user1/rpmbuild/RPMS/x86_64/pgspider16*.rpm /tmp/"
rm -f $ARTIFACT_DIR/*-debuginfo-*.rpm

# Push rpm binary to registry
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then
    ./docker/validate_parameters.sh ACCESS_TOKEN PGSPIDER_PROJECT_ID API_V4_URL
    curl_command="curl --header \"PRIVATE-TOKEN: ${ACCESS_TOKEN}\" --insecure --upload-file"
    package_uri="$API_V4_URL/projects/${PGSPIDER_PROJECT_ID}/packages/generic/rpm_rhel8/${PGSPIDER_BASE_POSTGRESQL_VERSION}"

    # pgspider
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # contrib
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # debugsource
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # devel
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # docs
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # libs
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # llvmjit
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # plperl
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # pltcl
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # server
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # test
    eval "$curl_command ${ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
else
    ./docker/validate_parameters.sh ACCESS_TOKEN OWNER_GITHUB PGSPIDER_PROJECT_GITHUB PGSPIDER_RELEASE_ID
    curl_command="curl -L \
                            -X POST \
                            -H \"Accept: application/vnd.github+json\" \
                            -H \"Authorization: Bearer ${ACCESS_TOKEN}\" \
                            -H \"X-GitHub-Api-Version: 2022-11-28\" \
                            -H \"Content-Type: application/octet-stream\" \
                            --retry 20 \
                            --retry-max-time 120 \
                            --insecure"
    assets_uri="https://uploads.github.com/repos/${OWNER_GITHUB}/${PGSPIDER_PROJECT_GITHUB}/releases/${PGSPIDER_RELEASE_ID}/assets"
    binary_dir="--data-binary \"@${ARTIFACT_DIR}\""

    # pgspider
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # contrib
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # debugsource
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # devel
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # docs
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # libs
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # llvmjit
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # plperl
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # pltcl
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # server
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
    # test
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${PACKAGE_RELEASE_VERSION}.rhel8.x86_64.rpm"
fi

# Clean
docker rmi $IMAGE_NAME_RPM
