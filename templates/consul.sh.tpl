#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

# Setup Consul
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/systemd/system/consul.d
sudo tee /etc/systemd/system/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "advertise_addr_wan": "$PUBLIC_IP",
  "data_dir": "/mnt/consul",
  "disable_remote_exec": false,
  "disable_update_check": true,
  "leave_on_terminate": true,
  ${config}
}
EOF


wget https://github.com/hashicorp/consul/blob/master/terraform/shared/scripts/rhel_consul.service?raw=true -O consul.service

echo "Installing Systemd service..."
sudo mkdir -p /etc/systemd/system/consul.d
sudo chown root:root /tmp/consul.service
sudo mv /tmp/consul.service /etc/systemd/system/consul.service
sudo chmod 0644 /etc/systemd/system/consul.service

sudo systemctl enable consul.service
sudo systemctl start consul.service

echo "Installing Nomad..."

curl -sLo nomad.zip https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip
wget https://github.com/hashicorp/nomad/blob/master/dist/systemd/nomad.service?raw=true -O nomad.service


echo "Installing Nomad..."
unzip nomad.zip >/dev/null
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad

pwd
sudo mkdir -p /etc/nomad
sudo mkdir -p /etc/systemd/system
sudo chown root:root /tmp/nomad.service
sudo mv /tmp/nomad.service /etc/systemd/system/nomad.service

sudo tee /etc/nomad/config.hcl > /dev/null <<EOF
bind_addr = "0.0.0.0"
data_dir = "/opt/nomad/data"
log_level = "DEBUG"

region = "eu"

datacenter = "dc1"

advertise {
  http = "$PRIVATE_IP:4646"
  rpc = "$PRIVATE_IP:4647"
  serf = "$PRIVATE_IP:4648"
}

${nomad_config}

EOF

sudo systemctl enable nomad.service
sudo systemctl start nomad.service

sudo apt-get install -y docker.io
sudo usermod -aG docker $(whoami)
sudo systemctl enable docker.service
sudo systemctl start docker.service

sudo mkdir ~/Prometheus/node_exporter
cd ~/Prometheus/node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.14.0/node_exporter-0.14.0.linux-amd64.tar.gz
tar -xvzf node_exporter-0.14.0.linux-amd64.tar.gz

cd node_exporter-0.14.0.linux-amd64
mv * .. 


sudo tee /etc/systemd/system/node_exporter.service >/dev/null <<EOF
[Unit]
Description=Node Exporter

[Service]
User=prometheus
ExecStart=/home/prometheus/Prometheus/node_exporter/node_exporter

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter.service
sudo systemctl start node_exporter.service


