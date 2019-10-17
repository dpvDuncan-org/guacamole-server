# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}alpine

# see hooks/post_checkout
ARG ARCH
COPY .gitignore qemu-${ARCH}-static* /usr/bin/

# see hooks/build and hooks/.config
ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}debian:stretch-slim

# see hooks/post_checkout
ARG ARCH
COPY qemu-${ARCH}-static /usr/bin

# Environment variables
ARG GUACD_Version
ENV GUACD_Version="${GUACD_Version}"

# Environment variables
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/local/lib"
ENV C_INCLUDE_PATH="${C_INCLUDE_PATH:+$C_INCLUDE_PATH:}/usr/local/include"

#ENV LC_ALL="en_US.UTF-8"
ENV GUACD_RUN_DEPS="libcairo2 libjpeg62-turbo libpng16-16 libossp-uuid16 libavcodec57 libavutil55 libswscale4 libpango1.0-0 libssh2-1 libtelnet2 libvncserver1 libvncclient1 libpulse0 libssl1.0.2 libvorbis0a libwebp6 libxkbfile1 libasound2 libfreerdp-client1.1 libfreerdp-cache1.1 libfreerdp-gdi1.1 libfreerdp-rail1.1"

ENV Common_BUILD_DEPS="build-essential curl"

ENV GUACD_BUILD_DEPS="libcairo2-dev libjpeg62-turbo-dev libpng-dev libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev libfreerdp-dev"

###### Install & Download Prerequisites ######
RUN DEBIAN_FRONTEND=noninteractive && \
    ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get update -qq && \
    apt-get upgrade -qq && \
    apt-get dist-upgrade -qq && \
    apt-get autoremove -qq && \
    apt-get autoclean -qq && \
    apt-get install -qq $GUACD_RUN_DEPS $Common_BUILD_DEPS $GUACD_BUILD_DEPS && \
    cd /tmp && \
    mkdir guacamole-server && \
    curl -L "https://github.com/apache/guacamole-server/archive/${GUACD_Version}.tar.gz" | tar -xz -C /tmp/guacamole-server --strip-components=1 && \
    cd /tmp/guacamole-server && \
    autoreconf -fi && \
    ./configure && \
    sleep 10 && \
    make && \
    make install && \
    apt-get purge -qq $Common_BUILD_DEPS $GUACD_BUILD_DEPS && \
    apt-get autoremove -qq && \
    apt-get autoclean && \
    rm -rf /tmp/*

# ports and volumes
EXPOSE 4822

CMD [ "/usr/local/sbin/guacd", "-b", "0.0.0.0", "-f" ]