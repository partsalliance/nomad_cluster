resource "aws_instance" "nomad_master_server" {
	count = "${var.servers}"
	ami = "${var.ubuntu_ami}"
	key_name = "${var.key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
	subnet_id = "${module.vpc.public_subnet_cidr}"
	instance_type = "${var.instance_master}"
	vpc_security_group_ids = ["${aws_security_group.nomad_master_server_sg.id}"]

	tags = "${map(
    "Name", "Nomad_Master_Server-${count.index}",
    var.consul_join_tag_key, var.consul_join_tag_value
    )}"

    root_block_device {
      delete_on_termination = true
      volume_type = "gp2"
      volume_size = "30"
    }

    user_data = <<EOF
#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sed -i -e "s/{PRIVATE_IP}/$${IP}/g" /etc/consul.d/server.json
sed -i -e "s/{PUBLIC_IP}/$${PUBLIC_IP}/g" /etc/consul.d/server.json
sed -i -e 's/{consul_join_tag_key}/${var.consul_join_tag_key}/g' /etc/consul.d/server.json
sed -i -e 's/{consul_join_tag_value}/${var.consul_join_tag_value}/g' /etc/consul.d/server.json

sed -i -e "s/{PRIVATE_IP}/$${IP}/g" /etc/nomad.d/server.hcl

systemctl enable nomad-server
systemctl enable consul-server
systemctl start nomad-server
systemctl start consul-server
EOF
}
