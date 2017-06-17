#!/usr/bin/env bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e

cd /tmp
sudo wget https://github.com/prometheus/prometheus/releases/download/v1.7.1/prometheus-1.7.1.linux-amd64.tar.gz

sudo tar xvfz prometheus-*.tar.gz
sudo rm prometheus-*.tar.gz

sudo mv prometheus-* /usr/bin


sudo tee /usr/bin/prometheus-1.7.1.linux-amd64/prometheus.yml >/dev/null <<EOF
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
      monitor: 'codelab-monitor'

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first.rules"
  # - "second.rules"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config
    - job_name: node
    # If prometheus-node-exporter is installed, grab stats about the local
    # machine by default
      ec2_sd_configs:
        - region: us-west-2
          profile: alpha-test-consul-join
          port: 9100
      relabel_configs:
        # Only monitor instances with a Name starting with "SD Demo"
        - source_labels: [__meta_ec2_tag_Name]
          regex: Nomad.*
          action: keep
EOF

cd /usr/bin/prometheus-1.7.1.linux-amd64
./prometheus -config.file=/usr/bin/prometheus-1.7.1.linux-amd64/prometheus.yml


