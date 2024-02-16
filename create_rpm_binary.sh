#!/bin/sh

source ./env_rpm_optimize_image.conf

set -eE

# download postgres documentation
if [[ ! -f postgresql-16-A4.pdf ]]; then
    wget https://www.postgresql.org/files/documentation/pdf/16/postgresql-16-A4.pdf
fi

# Create Docker image for creating RPM file of PGSpider.
docker build -t $IMAGE_NAME_RPM \
        --build-arg proxy=${proxy} \
        --build-arg no_proxy=${no_proxy} \
        --build-arg PGSPIDER_BASE_POSTGRESQL_VERSION=${PGSPIDER_BASE_POSTGRESQL_VERSION} \
        --build-arg PGSPIDER_RELEASE_VERSION=${PGSPIDER_RELEASE_VERSION} \
        --build-arg DISTRIBUTION_TYPE=${RPM_DISTRIBUTION_TYPE} \
        -f $DOCKERFILE_RPM .

# Get RPM file from container image.
rm -rf $RPM_ARTIFACT_DIR || true
mkdir -p $RPM_ARTIFACT_DIR
docker run --rm -v $(pwd)/$RPM_ARTIFACT_DIR:/tmp \
                -u "$(id -u $USER):$(id -g $USER)" \
                -e LOCAL_UID=$(id -u $USER) \
                -e LOCAL_GID=$(id -g $USER) $IMAGE_NAME_RPM /bin/sh \
                -c "cp /home/user1/rpmbuild/RPMS/x86_64/pgspider16*.rpm /tmp/"
rm -f $RPM_ARTIFACT_DIR/*-debuginfo-*.rpm

# # Push rpm binary to registry
if [[ $location == [gG][iI][tT][lL][aA][bB] ]];
then
    curl_command="curl --header \"PRIVATE-TOKEN: ${ACCESS_TOKEN}\" --insecure --upload-file"
    package_uri="https://tccloud2.toshiba.co.jp/swc/gitlab/api/v4/projects/${PGSPIDER_PROJECT_ID}/packages/generic/rpm_${RPM_DISTRIBUTION_TYPE}/${PGSPIDER_BASE_POSTGRESQL_VERSION}"

    # pgspider
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # contrib
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # debugsource
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # devel
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # docs
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # libs
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # llvmjit
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # plperl
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # pltcl
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # server
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # test
    eval "$curl_command ${RPM_ARTIFACT_DIR}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $package_uri/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
else
    curl_command="curl -L \
                            -X POST \
                            -H \"Accept: application/vnd.github+json\" \
                            -H \"Authorization: Bearer ${ACCESS_TOKEN}\" \
                            -H \"X-GitHub-Api-Version: 2022-11-28\" \
                            -H \"Content-Type: application/octet-stream\" \
                            --insecure"
    assets_uri="https://uploads.github.com/repos/${OWNER_GITHUB}/${PGSPIDER_PROJECT_GITHUB}/releases/${PGSPIDER_RELEASE_ID}/assets"
    binary_dir="--data-binary \"@${RPM_ARTIFACT_DIR}\""

    # pgspider
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # contrib
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # debugsource
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-debugsource-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # devel
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # docs
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-docs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # libs
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # llvmjit
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-llvmjit-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # plperl
    eval "$curl_command $assets_uri?name=name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-plperl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # pltcl
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-pltcl-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # server
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
    # test
    eval "$curl_command $assets_uri?name=pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm \
                        $binary_dir/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-test-${PGSPIDER_RELEASE_VERSION}-${RPM_DISTRIBUTION_TYPE}.x86_64.rpm"
fi

# Clean
docker rmi $IMAGE_NAME_RPM
