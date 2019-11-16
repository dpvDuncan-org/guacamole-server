ARG BASE_IMAGE_PREFIX

FROM multiarch/qemu-user-static as qemu

FROM ${BASE_IMAGE_PREFIX}debian:stable-slim

COPY --from=qemu /usr/bin/qemu-*-static /usr/bin/
COPY scripts/start.sh /
COPY guacamole-server /tmp/

# Environment variables
ENV GUACD_Version="1.0.0"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/local/lib"
ENV C_INCLUDE_PATH="${C_INCLUDE_PATH:+$C_INCLUDE_PATH:}/usr/local/include"

#ENV LC_ALL="en_US.UTF-8"
ENV GUACD_RUN_DEPS="libcairo2 libjpeg62-turbo libpng16-16 libossp-uuid16 libavcodec57 libavutil55 libswscale4 libpango1.0-0 libssh2-1 libtelnet2 libvncserver1 libvncclient1 libpulse0 libssl1.0.2 libvorbis0a libwebp6 libxkbfile1 libasound2 libfreerdp-client1.1 libfreerdp-cache1.1 libfreerdp-gdi1.1 libfreerdp-rail1.1"

ENV Common_BUILD_DEPS="build-essential curl"

ENV GUACD_BUILD_DEPS="libcairo2-dev libjpeg62-turbo-dev libpng-dev libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev libfreerdp-dev"

ENV DEBIAN_FRONTEND noninteractive

###### Install & Download Prerequisites ######
RUN echo 'Dpkg::Use-Pty "0";' > /etc/apt/apt.conf.d/00usepty
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get update -qq
RUN apt-get upgrade -qq
RUN apt-get dist-upgrade -qq
RUN apt-get autoremove -qq
RUN apt-get autoclean -qq
RUN apt-get install -qq $GUACD_RUN_DEPS $Common_BUILD_DEPS $GUACD_BUILD_DEPS
WORKDIR /tmp/guacamole-server
RUN autoreconf -fi
RUN ./configure
RUN make
RUN make install
RUN apt-get purge -qq $Common_BUILD_DEPS $GUACD_BUILD_DEPS
RUN apt-get autoremove -qq
RUN apt-get autoclean -qq
WORKDIR /

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /usr/bin/qemu-*-static

# ports and volumes
EXPOSE 4822

CMD [ "/start.sh" ]