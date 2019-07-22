# A minimal Docker image with Nodejs, Java and Puppeteer
#
# Based upon:
# https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker

#JAVA install
FROM alpine:3.2

# Install cURL
RUN apk --update add curl ca-certificates tar && 
    curl -Ls https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk && 
    apk add --allow-untrusted /tmp/glibc-2.21-r2.apk
# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 45
ENV JAVA_VERSION_BUILD 14
ENV JAVA_PACKAGE       jdk
# Download and unarchive Java
RUN mkdir /opt && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie"
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz 
    | tar -xzf - -C /opt &&
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&
    rm -rf /opt/jdk/*src.zip 
           /opt/jdk/lib/missioncontrol 
           /opt/jdk/lib/visualvm 
           /opt/jdk/lib/*javafx* 
           /opt/jdk/jre/lib/plugin.jar 
           /opt/jdk/jre/lib/ext/jfxrt.jar 
           /opt/jdk/jre/bin/javaws 
           /opt/jdk/jre/lib/javaws.jar 
           /opt/jdk/jre/lib/desktop 
           /opt/jdk/jre/plugin 
           /opt/jdk/jre/lib/deploy* 
           /opt/jdk/jre/lib/*javafx* 
           /opt/jdk/jre/lib/*jfx* 
           /opt/jdk/jre/lib/amd64/libdecora_sse.so 
           /opt/jdk/jre/lib/amd64/libprism_*.so 
           /opt/jdk/jre/lib/amd64/libfxplugins.so 
           /opt/jdk/jre/lib/amd64/libglass.so 
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so 
           /opt/jdk/jre/lib/amd64/libjavafx*.so 
           /opt/jdk/jre/lib/amd64/libjfx*.so
#Environment variables export
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

#Node-js and Puppeteer import
FROM node:10.16.0-slim@sha256:e1a87966f616295140efb069385fabfe9f73a43719b607ed3bc8d057a20e5431
    
RUN  apt-get update \
     && apt-get install -y wget --no-install-recommends \
     && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
     && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
     && apt-get update \
     && apt-get install -y google-chrome-unstable --no-install-recommends \
     && rm -rf /var/lib/apt/lists/* \
     && wget --quiet https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /usr/sbin/wait-for-it.sh \
     && chmod +x /usr/sbin/wait-for-it.sh \

ADD package.json package-lock.json /
RUN npm install