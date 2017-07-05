advertise {
  http = "{PRIVATE_IP}"
  rpc  = "{PRIVATE_IP}"
  serf = "{PRIVATE_IP}"
}

data_dir = "/opt/nomad"

region = "eu"

datacenter = "dc1"

client {
  enabled      = true
  no_host_uuid = true
}