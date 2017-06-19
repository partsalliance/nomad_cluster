#!/usr/bin/env bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e

cd /tmp
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.3.1_amd64.deb
sudo apt-get install -y adduser libfontconfig
sudo dpkg -i grafana_4.3.1_amd64.deb
sudo systemctl daemon-reload
sudo systemctl start grafana-server.service