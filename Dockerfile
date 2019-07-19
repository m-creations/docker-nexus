## -*- docker-image-name: "mcreations/nexus" -*-

#
# Nexus 3 Container
#
# Dependencies:
#
# Volume: /data
#

FROM mcreations/openwrt-java:8
MAINTAINER Kambiz Darabi <darabi@m-creations.net>

ENV APP_VERSION 3.17.0-01
ENV APP_ARCHIVE nexus-${APP_VERSION}-unix.tar.gz

ENV SONATYPE_WORK=/data/sonatype-work
VOLUME /data

# configure nexus runtime
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus \
    NEXUS_CONTEXT='' \
    INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m -XX:MaxDirectMemorySize=2g -Djava.util.prefs.userRoot=${SONATYPE_WORK}/javaprefs "

EXPOSE 8081

ENV JAVA_MAX_MEM 1200m
ENV JAVA_MIN_MEM 1200m
ENV EXTRA_JAVA_OPTS ""

ENV NEXUS_UID 200
ENV NEXUS_GID 200

ADD image/root /

RUN opkg update && opkg install shadow-useradd shadow-groupadd coreutils-stat &&\
    groupadd -g ${NEXUS_GID} nexus &&\
    useradd -u ${NEXUS_UID} -g ${NEXUS_GID} --home-dir /opt/nexus --no-create-home nexus --shell /bin/false &&\
    opkg --force-removal-of-dependent-packages remove libiconv-full libintl-full &&\
    rm /tmp/opkg-lists/* &&\
    wget --progress dot:giga https://download.sonatype.com/nexus/3/${APP_ARCHIVE} &&\
    tar xzf ${APP_ARCHIVE} &&\
    rm ${APP_ARCHIVE} &&\
    mkdir -p ${SONATYPE_DIR} &&\
    mv nexus-${APP_VERSION} ${SONATYPE_DIR}/nexus &&\
    sed -i -e "s|-XX:LogFile=.*|-XX:LogFile=${SONATYPE_WORK}/nexus3/log/jvm.log|g" \
        -e "s|karaf.data=.*|karaf.data=${SONATYPE_WORK}/nexus3|g" \
        -e "s|java.io.tmpdir=.*|java.io.tmpdir=${SONATYPE_WORK}/nexus3/tmp|g" ${NEXUS_HOME}/bin/nexus.vmoptions &&\
    chown -R nexus:nexus ${SONATYPE_DIR}

CMD /nexus
