#!/bin/bash
set -e

sudo apt-get update -y
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
sudo newgrp docker
sudo systemctl start docker
sudo systemctl enable docker
mkdir -p /etc/elasticsearch /etc/kibana/ /etc/filebeat /opt/elasticsearch /opt/kibana/ /opt/filebeat
sudo docker pull docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2
sudo docker pull docker.elastic.co/kibana/kibana-oss:7.10.2
sudo docker pull docker.elastic.co/beats/filebeat-oss:7.11.0
sudo docker network create elastic


sudo tee /opt/elasticsearch/Dockerfile > /dev/null <<EOF
FROM docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2
EXPOSE 9200
EXPOSE 9300
VOLUME ["/etc/elasticsearch"]
EOF

sudo tee /opt/kibana/Dockerfile > /dev/null <<EOF
FROM docker.elastic.co/kibana/kibana-oss:7.10.2
EXPOSE 5601
COPY kibana.yml /etc/kibana/kibana.yml
VOLUME ["/etc/kibana"]
EOF

sudo tee /opt/filebeat/Dockerfile > /dev/null <<EOF
FROM docker.elastic.co/beats/filebeat-oss:7.10.2
COPY filebeat.yml /etc/filebeat/filebeat.yml
VOLUME ["/etc/filebeat"]
EOF

tee /opt/kibana/kibana.yml > /dev/null <<EOF
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
EOF

# filebeat
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.10.2-amd64.deb
dpkg -i filebeat-*.deb


sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.BCK
cat <<\EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
  - type: log
    enabled: false
    paths:
      - /var/log/auth.log
  - type: docker
    containers:
      path: "/var/lib/docker/containers"
      stream: "all"
      ids:
        - "*"
    processors:
      - add_docker_metadata:
          host: "unix:///var/run/docker.sock"

filebeat.modules:
  - module: system
    syslog:
      enabled: true
    auth:
      enabled: true
  - module: postgresql
    log:
      enabled: true

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

filebeat.autodiscover:
  providers:
    - type: docker
      hints.enabled: true
      templates:
        - condition:
            contains:
              docker.container.labels.log-enabled: "true"
          config:
            - type: container
              paths:
                - /var/lib/docker/containers/${data.docker.container.id}/*.log

setup.kibana.host: "http://localhost:5601"
setup.dashboards.enabled: true

setup.template.name: "filebeat"
setup.template.pattern: "filebeat-*"
setup.template.settings:
  index.number_of_shards: 1

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
seccomp:
  default_action: allow 
  syscalls:
  - action: allow
    names:
    - rseq

output.elasticsearch:
  hosts: [ "localhost:9200" ]
  index: "filebeat-%{[agent.version]}-%{+yyyy.MM.dd}"
EOF

cd /opt/elasticsearch/
docker build -t elasticsearch .
sudo docker run -d --network=elastic --name elasticsearch --restart=always -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch

cd /opt/kibana/
docker build -t kibana .
sudo docker run -d --network=elastic --name kibana --restart=always -p 5601:5601 kibana

sleep 60

sudo systemctl enable filebeat
sudo systemctl start filebeat