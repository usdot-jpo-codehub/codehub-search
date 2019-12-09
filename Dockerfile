FROM elasticsearch:7.2.0 AS builder

RUN yum install -y gcc-c++ make
RUN curl -SsL https://rpm.nodesource.com/setup_10.x > node_install.sh
RUN sh node_install.sh
RUN yum install nodejs -y

RUN node --version
RUN npm --version

RUN npm install -g elasticdump@4.1.1
RUN elasticdump --version

ADD data /data
ADD schemas /schemas
ADD full-populate.sh /full-populate.sh

ENV ELASTICSEARCH_URL="http://localhost:9200"

RUN /usr/local/bin/docker-entrypoint.sh elasticsearch -d -E "discovery.type=single-node" \
    && echo "Waiting..." && while [ "$(curl -s -o /dev/null -w '%{response_code}' $ELASTICSEARCH_URL)" != "200" ]; do sleep 2; done \
    && /full-populate.sh