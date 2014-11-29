FROM ubuntu:14.04
 
RUN apt-get update

#Runit
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#Install Oracle Java 7
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' > /etc/apt/sources.list.d/java.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer

#ElasticSearch
RUN curl https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.1.tar.gz | tar xz && \
    mv elasticsearch-* elasticsearch

#Kibana
RUN curl https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz | tar xz && \
    mv kibana-* kibana

#NGINX
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

#Add runit services
ADD sv /etc/service 

#Configuration
ADD nginx.conf /etc/nginx/
RUN sed -i -e 's|elasticsearch:.*|elasticsearch: "http://"+window.location.hostname + ":" + window.location.port,|' /kibana/config.js

#80=ngnx, 9200=elasticsearch
EXPOSE 80 9200
