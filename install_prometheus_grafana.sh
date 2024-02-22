#!/bin/bash
 sudo useradd --system --no-create-home --shell /bin/false prometheus 
 sudo apt install wget -y
 wget https://github.com/prometheus/prometheus/releases/download/v2.47.1/prometheus-2.47.1.linux-amd64.tar.gz
 tar -xvf prometheus-2.47.1.linux-amd64.tar.gz
 sudo mkdir -p /data /etc/prometheus
 cd prometheus-2.47.1.linux-amd64/
 sudo mv prometheus promtool /usr/local/bin/
 sudo mv consoles/ console_libraries/ /etc/prometheus/
 sudo mv prometheus.yml /etc/prometheus/prometheus.yml
 sudo chown -R prometheus:prometheus /etc/prometheus/ /data/
 cd
 rm -rf prometheus-2.47.1.linux-amd64.tar.gz
 sudo touch /etc/systemd/system/prometheus.service
 echo "
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/data --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries --web.listen-address=0.0.0.0:9090
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/prometheus.service

sudo systemctl enable prometheus
sudo systemctl start prometheus


sudo apt-get install -y apt-transport-https software-properties-common 
sudo mkdir -p /etc/apt/keyrings/

wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

sudo apt-get update
sudo apt-get -y install grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
