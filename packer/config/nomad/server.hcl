advertise {
  http = "{PRIVATE_IP}"
  rpc  = "{PRIVATE_IP}"
  serf = "{PRIVATE_IP}"
}

data_dir = "/opt/nomad"

region = "eu"

datacenter = "dc1"

server {
  enabled          = true
  bootstrap_expect = 3
}