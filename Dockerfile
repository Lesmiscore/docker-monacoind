FROM ubuntu AS build

ENV DEBIAN_FRONTEND=noninteractive
ARG REF=v0.14.2rc1

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y build-essential \
    libtool autotools-dev autoconf \
    libssl-dev \
    libboost-all-dev \
    libevent-dev \
    pkg-config \
    software-properties-common \
    git && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-get update && \
  apt-get install -y libdb4.8-dev libdb4.8++-dev && \
  git clone https://github.com/monacoinproject/monacoin /monacoin && \
  cd /monacoin && \
  git checkout "$REF" && \
  ./autogen.sh && \
  ./configure --prefix=/usr --without-miniupnpc --without-gui --disable-tests && \
  make -j4

FROM ubuntu

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    libssl-dev \
    libboost-all-dev \
    libevent-dev \
    software-properties-common && \
  add-apt-repository -y ppa:bitcoin/bitcoin && \
  apt-get update && \
  apt-get install -y libdb4.8-dev libdb4.8++-dev && \
  apt-get autoremove -y software-properties-common && \
  apt-get clean

COPY --from=build /monacoin/src/monacoind /usr/bin/monacoind

VOLUME /root/.monacoin
EXPOSE 9402

ENTRYPOINT [ "/usr/bin/monacoind" ]
