output "servers" {
  value = ["${aws_instance.nomad_master_server.*.public_ip}"]
}