#
# TinyMediaManager Dockerfile
#

#FROM jlesage/baseimage-gui:alpine-3.8
#FROM jlesage/baseimage-gui:alpine-3.5-glibc-v3.3.4
FROM jlesage/baseimage-gui:alpine-3.8-glibc
# Define software download URLs.
ARG TMM_URL=https://github.com/tinyMediaManager/tinyMediaManager/archive/tinyMediaManager-2.9.16.tar.gz
ARG ORACLEJAVAJRE_URL=http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/server-jre-8u131-linux-x64.tar.gz

# Define working directory.
WORKDIR /tmp

# Download TinyMediaManager
RUN \
    mkdir -p /defaults && \
    wget ${TMM_URL} -O /defaults/tmm.tar.gz

# Download and install Oracle JRE.
# NOTE: This is needed only for the 7-Zip-JBinding workaround.
RUN \
    add-pkg --virtual build-dependencies curl && \
    mkdir /opt/jre && \
    curl -# -L -H "Cookie: oraclelicense=accept-securebackup-cookie" ${ORACLEJAVAJRE_URL} | tar -xz --strip 2 -C /opt/jre jdk1.8.0_131/jre && \
    rm -r /opt/jre/lib/oblique-fonts && \
    del-pkg build-dependencies

# Install dependencies.
RUN \
    add-pkg \
        # For the 7-Zip-JBinding workaround, Oracle JRE is needed instead of
        # the Alpine Linux's openjdk native package.
        # The libstdc++ package is also needed as part of the 7-Zip-JBinding
        # workaround.
        #openjdk8-jre \
        libmediainfo \
        ttf-dejavu

# Maximize only the main/initial window.
RUN \
    sed-patch 's/<application type="normal">/<application type="normal" title="tinyMediaManager \/ 2.9.13">/' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/tinyMediaManager/tinyMediaManager/raw/master/AppBundler/tmm.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="TinyMediaManager" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/media"]

# Metadata.
LABEL \
      org.label-schema.name="tinymediamanager" \
      org.label-schema.description="Docker container for TinyMediaManager" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/romancin/tmm-docker" \
      org.label-schema.schema-version="1.0"
