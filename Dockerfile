FROM alpine

ENV ECFLOW_VERSION 4.6.1

RUN mkdir /tmp/ecflow_build

RUN apk --update add --virtual build-dependencies ca-certificates wget cmake boost-dev build-base g++ linux-headers openssl python3-dev && \
    update-ca-certificates && \
    cd /tmp/ecflow_build && \
    export WK=/tmp/ecflow_build/ecFlow-${ECFLOW_VERSION}-Source && \
    wget -O ecFlow.tgz "https://software.ecmwf.int/wiki/download/attachments/8650755/ecFlow-$ECFLOW_VERSION-Source.tar.gz" && \
    tar -zxf ecFlow.tgz && rm ecFlow.tgz && \
    cd ${WK} && mkdir build && cd build && \
    #cmake -DPYTHON_EXECUTABLE=/usr/bin/python3 -DBOOST_ROOT=/usr -DCMAKE_CXX_FLAGS="-w -fPIC" -DENABLE_GUI=OFF -DENABLE_UI=OFF .. && \
    cmake -DENABLE_PYTHON=OFF -DBOOST_ROOT=/usr -DCMAKE_CXX_FLAGS=-w -DENABLE_GUI=OFF -DENABLE_UI=OFF .. && \
    make -j$(grep processor /proc/cpuinfo | wc -l) && \
    make check && \
    make install && \
    rm -rf /tmp/ecflow_build && \
    apk del build-dependencies && \
    apk add libstdc++

RUN adduser -SD ecflow
WORKDIR /home/ecflow
USER ecflow

EXPOSE 3141

ENTRYPOINT ["/usr/local/bin/ecflow_server", "-d"]
