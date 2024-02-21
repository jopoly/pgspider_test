FROM rockylinux:8.8

ARG PGSPIDER_BASE_POSTGRESQL_VERSION
ARG PGSPIDER_RELEASE_VERSION
ARG DISTRIBUTION_TYPE
ARG PG_INS=/usr/pgsql-16

ARG ACCESS_TOKEN
# ARG PGSPIDER_RPM_URL=https://tccloud2.toshiba.co.jp/swc/gitlab/api/v4/projects/16/packages/generic/rpm_${DISTRIBUTION_TYPE}/${PGSPIDER_BASE_POSTGRESQL_VERSION}
ARG PGSPIDER_RPM_URL
ARG PGSPIDER_RPM_ID
ARG proxy
ARG no_proxy

LABEL name="PGSpider" \
	summary="Toshiba Corporation Corporate Software Engineering & Technology Center. Distributed Data Search Framework for utilization of big-data and IoT-data" \
	description="High-Performance SQL Cluster Engine for Scalable Data Virtualization." \
	pgspider.version.major="${PG_MAJOR}" \
	pgspider.version="${PG_VERSION}"

ENV http_proxy ${proxy}
ENV https_proxy ${proxy}
ENV no_proxy ${no_proxy}

# Add postgres repository for pgdg-srpm-macros
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

RUN dnf install -y wget pgdg-srpm-macros
RUN dnf --enablerepo=powertools install -y perl-IPC-Run sudo
RUN dnf --enablerepo=devel install -y snappy-devel

# Create pgspider user
# User on host will mapped to this user.
RUN useradd -m pgspider
RUN echo "pgspider:pgspider" | chpasswd
RUN usermod -aG wheel pgspider
RUN echo "pgspider ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install PGSpider
RUN if [[ -z ${ACCESS_TOKEN} ]]; then \
        wget -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
        ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm --no-check-certificate ; \
    else \
        curl --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" \
        ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm \
        -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
        --insecure ; \
    fi
RUN if [[ -z ${ACCESS_TOKEN} ]]; then \ 
        wget -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
        ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm --no-check-certificate ; \
    else \
        curl --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" \
        ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm \
        -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
        --insecure ; \
    fi

RUN if [[ -z ${ACCESS_TOKEN} ]]; then \ 
        wget -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
        ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm --no-check-certificate ; \
    else \
        curl --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" \
        ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm \
        -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
        --insecure ; \
    fi

RUN if [[ -z ${ACCESS_TOKEN} ]]; then \ 
        wget -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
         ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm --no-check-certificate ; \
    else \
        curl --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" \
        ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm \
        -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
        --insecure ; \
    fi

RUN if [[ -z ${ACCESS_TOKEN} ]]; then \ 
        wget -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
         ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm --no-check-certificate ; \
    else \
        curl --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" \
        ${PGSPIDER_RPM_URL}/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64${PGSPIDER_RPM_ID}.rpm \
        -o /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
        --insecure ; \
    fi

RUN dnf -y localinstall \
    --setopt=skip_missing_names_on_install=False \
    /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-libs-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
    /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
    /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-devel-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
    /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-contrib-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm \
    /root/pgspider${PGSPIDER_BASE_POSTGRESQL_VERSION}-server-${PGSPIDER_RELEASE_VERSION}-${DISTRIBUTION_TYPE}.x86_64.rpm


RUN mkdir -p /var/run/postgresql && chown -R pgspider:pgspider /var/run/postgresql && chmod 3777 /var/run/postgresql

ENV PGSDATA /var/lib/postgresql/data
# this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
RUN mkdir -p "$PGSDATA" && chown -R pgspider:pgspider "$PGSDATA" && chmod 1777 "$PGSDATA"

# open up the pgspider port
EXPOSE 4813

# setup entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

# unset proxy to avoid personal information security
ENV http_proxy =
ENV https_proxy =
ENV no_proxy =
RUN sed -i "s/.*proxy=.*/proxy=/g" /etc/dnf/dnf.conf

USER pgspider

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# After container was created, 
# 	set ENABLE_PSQL_CLIENT to show psql window.
# 	set DETACH_MODE to running in detach mode.
# If not set, the container with stop after running immediately.
CMD ENABLE_PSQL_CLIENT