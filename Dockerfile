# Snort in Docker
FROM ubuntu:18.04

MAINTAINER Moses Frost <moses@moses.io>

RUN apt-get update && \
apt-get install -y \
cmake \
hwloc \
libhwloc-dev \
libssl-dev \
openssl \
libluajit-5.1-dev \
libluajit-5.1.2 \
luajit \ 
python-setuptools \
python-pip \
python-dev \
pkg-config \
wget \
build-essential \
bison \
flex \
libpcap-dev \
libpcre3-dev \
libdumbnet-dev \
zlib1g-dev \
iptables-dev \
libnetfilter-queue1 \
tcpdump \
unzip 

# Define working directory.
WORKDIR /opt

ENV DAQ_VERSION 2.2.2
RUN wget https://www.snort.org/downloads/snortplus/daq-${DAQ_VERSION}.tar.gz \
&& tar xvfz daq-${DAQ_VERSION}.tar.gz \
&& cd daq-${DAQ_VERSION} \
&& ./configure; make; make install 

# This will break once Snort leaves beta because I've prepended the 
# downloaded file with the word -beta. 
RUN ldconfig 

ENV MY_PATH=/usr/local/snort
ENV SNORT_VERSION 3.0.0
RUN wget https://www.snort.org/downloads/snortplus/snort-${SNORT_VERSION}-beta.tar.gz \
&& tar xvfz snort-${SNORT_VERSION}-beta.tar.gz \
&& cd snort-${SNORT_VERSION} \
&& ./configure_cmake.sh --prefix=${MY_PATH} \
&& cd build \
&& make -j $(nproc) install 

RUN ldconfig

# For this to work you MUST have downloaded the snort3 subscribers ruleset.
# This has to be located in the directory we are currently in.

ENV SNORT_RULES_SNAPSHOT 3000
ADD snortrules-snapshot-${SNORT_RULES_SNAPSHOT}.tar.gz /opt
ADD entrypoint.sh /opt

RUN mkdir -p /var/log/snort && \
mkdir -p /usr/local/lib/snort_dynamicrules && \
mkdir -p /etc/snort && \
mkdir -p /etc/snort/rules && \
mkdir -p /etc/snort/preproc_rules && \
mkdir -p /etc/snort/etc && \

cp -r /opt/rules /etc/snort && \
cp -r /opt/preproc_rules /etc/snort && \
cp -r /opt/etc /etc/snort && \

touch /etc/snort/rules/local.rules && \
touch /etc/snort/rules/white_list.rules /etc/snort/rules/black_list.rules

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/opt/snort-${SNORT_VERSION}.tar.gz /opt/daq-${DAQ_VERSION}.tar.gz

ENV INTERFACE 'wlp4s0'
ENV LUA_PATH=${MY_PATH}/include/snort/lua/\?.lua\;\;
ENV SNORT_LUA_PATH=${MY_PATH}/etc/snort

# Validate an installation
RUN ${MY_PATH}/bin/snort -c /etc/snort/etc/snort.lua
RUN chmod a+x /opt/entrypoint.sh

# Let's run snort!
CMD ["-i", "wlp4s0"]
ENTRYPOINT ["/opt/entrypoint.sh"]
#CMD ["/usr/local/snort/bin/snort", "-d", "-i", "eth0", "-c", "/etc/snort/etc/snort.lua"]

