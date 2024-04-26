FROM eclipse-temurin:8u412-b08-jdk-focal
WORKDIR /warp10

ARG WARP10_VERSION=3.2.0
ARG FDB_VERSION=7.1.26

RUN apt update && apt upgrade -y
RUN apt install wget curl -y

RUN curl -L -o foundationdb-clients_amd64.deb https://github.com/apple/foundationdb/releases/download/7.1.26/foundationdb-clients_${FDB_VERSION}-1_amd64.deb
RUN dpkg -i foundationdb-clients_amd64.deb

RUN curl -L -o warp10.tar.gz https://github.com/senx/warp10-platform/releases/download/${WARP10_VERSION}/warp10-${WARP10_VERSION}.tar.gz
RUN tar zxpvf warp10.tar.gz
RUN mv warp10-${WARP10_VERSION}/ warpInstall
WORKDIR /warp10/warpInstall

RUN ./bin/warp10.sh init standalone+