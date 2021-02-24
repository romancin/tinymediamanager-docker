#
# TinyMediaManager Dockerfile
#
FROM jlesage/baseimage-gui:alpine-3.12-glibc

# Define software versions.
ARG JAVAJRE_VERSION=8.265.01.1
ARG TMM_VERSION=3.1.12.1

# Define software download URLs.
ARG TMM_URL=http://release.tinymediamanager.org/v3/dist/tmm_${TMM_VERSION}_linux.tar.gz
ARG JAVAJRE_URL=https://corretto.aws/downloads/resources/${JAVAJRE_VERSION}/amazon-corretto-${JAVAJRE_VERSION}-linux-x64.tar.gz
ENV JAVA_HOME=/opt/jre/bin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jre/bin
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
    curl -# -L ${JAVAJRE_URL} | tar -xz --strip 2 -C /opt/jre amazon-corretto-${JAVAJRE_VERSION}-linux-x64/jre && \
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
        ttf-dejavu \
        bash

# Maximize only the main/initial window.
# It seems this is not needed for TMM 3.X version.
#RUN \
#    sed-patch 's/<application type="normal">/<application type="normal" title="tinyMediaManager \/ 3.0.2">/' \
#        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://gitlab.com/tinyMediaManager/tinyMediaManager/raw/45f9c702615a55725a508523b0524166b188ff75/AppBundler/tmm.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY VERSION /

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
