FROM alpine

ENV ECFLOW_VERSION 4.5.0
ENV BOOST_VERSION 1.53.0

RUN mkdir /tmp/ecflow_build

ADD py_u_TestSimulator.py.patch /tmp/ecflow_build

RUN apk --update add --virtual build-dependencies build-base cmake g++ linux-headers openssl python3-dev && \
    cd /tmp/ecflow_build && \
    export WK=/tmp/ecflow_build/ecFlow-${ECFLOW_VERSION}-Source && \
    export BOOST_UNDERSCORE_VERSION=$(echo $BOOST_VERSION | sed s/"\."/_/g) && \
    export BOOST_ROOT=/tmp/ecflow_build/boost_${BOOST_UNDERSCORE_VERSION} && \
    export BOOST_DOWNLOAD_NAME=boost_${BOOST_UNDERSCORE_VERSION}.tar.bz2 && \
    wget "https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/${BOOST_DOWNLOAD_NAME}" && \
    wget -O ecFlow.tgz "https://software.ecmwf.int/wiki/download/attachments/8650755/ecFlow-$ECFLOW_VERSION-Source.tar.gz" && \
    tar -zxf ecFlow.tgz && rm ecFlow.tgz && \
    tar -jxf ${BOOST_DOWNLOAD_NAME} && rm ${BOOST_DOWNLOAD_NAME} && \
    cd $BOOST_ROOT && \
    ./bootstrap.sh --with-python=/usr/bin/python3 && \
    sed -i "s|using python : 3.5 :  ;|using python : 3.5 : python3 : /usr/include/python3.5m ;|g" project-config.jam && \
    $WK/build_scripts/boost_build.sh && \
    cd $WK && \ 
    patch -p1 Pyext/test/py_u_TestSimulator.py < /tmp/ecflow_build/py_u_TestSimulator.py.patch && \
    mkdir build && cd build && \
    cmake -DCMAKE_CXX_FLAGS=-w -DENABLE_GUI=OFF -DENABLE_UI=OFF .. && \
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
