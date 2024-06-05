FROM ubuntu:focal-20240427 as base

ARG WEB_PORT=8314
ARG DB_DATA=1Cv8.1CD
ARG PLATFORM_VERSION=8.3.25.1257
ARG SETUP_NAME=setup-full-${PLATFORM_VERSION}-x86_64.run
ARG SETUP_URL=http://my-pc:8081/repository/raw/${SETUP_NAME}
    # my-pc:8081 is Nexus address
ENV PORT=${WEB_PORT}
ENV DB=${DB_DATA}
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp

RUN set -xe \ 
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    libgtk-3-0 libenchant1c2a libharfbuzz-icu0 libgstreamer1.0-0  \
    libgstreamer-plugins-base1.0-0 gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad libsecret-1-0 libsoup2.4-1 libgl1 libegl1 \
    libxrender1 libxfixes3 libxslt1.1 geoclue-2.0 \
    wget software-properties-common \
    && apt-add-repository multiverse \
    && apt-get update \
    && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
    && apt-get install -y --no-install-recommends fontconfig ttf-mscorefonts-installer \
    && wget -q ${SETUP_URL} \
    && chmod +x ${SETUP_NAME} \
    && ./${SETUP_NAME} --installer-language en --mode unattended --enable-components server \
    && rm ${SETUP_NAME} \
    && apt-get remove -y wget software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean


FROM scratch as platform

COPY --from=base / /

WORKDIR /opt/1cv8/x86_64/${PLATFORM_VERSION}

EXPOSE ${WEB_PORT}

CMD echo "You can connect with port $PORT" \
    && echo "Using ${DB}" \
    && echo "Current time is $(date)" \
    && ./ibsrv --data=/fs-data --address=any --port=$PORT