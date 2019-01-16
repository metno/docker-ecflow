FROM alpine:edge

ENV ECFLOW_VERSION 4.11.1

RUN mkdir /tmp/ecflow_build

RUN apk --update add --virtual build-dependencies ca-certificates wget cmake build-base g++ linux-headers openssl python3-dev boost-python3 boost-dev boost-static openssl-dev && \
    update-ca-certificates && \
    cd /tmp/ecflow_build && \
    export CORE_COUNT=$(grep processor /proc/cpuinfo | wc -l) && \
    export WK=/tmp/ecflow_build/ecFlow-${ECFLOW_VERSION}-Source && \
    wget -O ecFlow.tgz "https://software.ecmwf.int/wiki/download/attachments/8650755/ecFlow-$ECFLOW_VERSION-Source.tar.gz" && \
    tar -zxf ecFlow.tgz && rm ecFlow.tgz && \
    cd ${WK} && mkdir build && cd build && \
    export BOOST_ROOT=/usr && \
    cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_SERVER=on -DENABLE_PYTHON=on -DENABLE_SSL=on -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_CXX_FLAGS="-w -fPIC" -DENABLE_GUI=off -DENABLE_UI=off .. && \
    make -j$CORE_COUNT && \
    make check && \
    make install && \
    rm -rf /tmp/ecflow_build && \
    apk del build-dependencies && \
    apk add libstdc++ openssl

RUN adduser -SD ecflow
WORKDIR /home/ecflow
USER ecflow

EXPOSE 3141

ENTRYPOINT ["/usr/local/bin/ecflow_server", "-d"]
