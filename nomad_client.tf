resource "aws_instance" "nomad_client" {
	count = "${var.servers}"
	ami = "${var.ubuntu_ami}"
	key_name = "${var.key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
	subnet_id = "${module.vpc.public_subnet_cidr}"
	instance_type = "${var.instance_client}"
	vpc_security_group_ids = ["${aws_security_group.nomad_master_server_sg.id}"]

	tags = "${map(
    "Name", "Nomad_Client-${count.index}",
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
sed -i -e "s/{PRIVATE_IP}/$${IP}/g" /etc/consul.d/client.json
sed -i -e "s/{PUBLIC_IP}/$${PUBLIC_IP}/g" /etc/consul.d/client.json
sed -i -e 's/{consul_join_tag_key}/${var.consul_join_tag_key}/g' /etc/consul.d/client.json
sed -i -e 's/{consul_join_tag_value}/${var.consul_join_tag_value}/g' /etc/consul.d/client.json

sed -i -e "s/{PRIVATE_IP}/$${IP}/g" /etc/nomad.d/client.hcl

sudo systemctl enable nomad-client
sudo systemctl enable consul-client
sudo systemctl start nomad-client
sudo systemctl start consul-client
EOF
}
