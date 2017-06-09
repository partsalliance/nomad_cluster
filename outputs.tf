output "servers_public" {
  value = ["${aws_instance.nomad_master_server.*.public_ip}"]
}

output "servers_private" {
  value = ["${aws_instance.nomad_master_server.*.private_ip}"]
}

output "clients_public" {
	value = ["${aws_instance.nomad_client.*.public_ip}"]
}

output "clients_private" {
	value = ["${aws_instance.nomad_client.*.private_ip}"]
}