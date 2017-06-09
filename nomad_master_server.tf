resource "aws_instance" "nomad_master_server" {
	count = "${var.servers}"
	ami = "${var.ubuntu_ami}"
	key_name = "${var.key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
	subnet_id = "${module.vpc.public_subnet_cidr}"
	instance_type = "${var.instance_master}"
	vpc_security_group_ids = ["${aws_security_group.nomad_master_server_sg.id}"]

  user_data = "${element(data.template_file.server.*.rendered, count.index)}"

	tags = "${map(
    "Name", "Nomad_Master_Server-${count.index}",
    var.consul_join_tag_key, var.consul_join_tag_value
    )}"

    root_block_device {
      delete_on_termination = true
      volume_type = "gp2"
      volume_size = "30"
    }
}

data "template_file" "server" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/consul.sh.tpl")}"

  vars {
    consul_version = "0.8.2"
    nomad_version = "0.5.6"

    config = <<EOF
     "bootstrap_expect": 3,
     "node_name": "${var.namespace}-server-${count.index}",
     "retry_join_ec2": {
       "tag_key": "${var.consul_join_tag_key}",
       "tag_value": "${var.consul_join_tag_value}"
     },
     "server": true
    EOF

    nomad_config = <<EOF
    server {
      rejoin_after_leave = true
      enabled = true
      bootstrap_expect = 3
    }

    consul {
      server_service_name = "nomad-server"
      server_auto_join = true
      auto_advertise = true
      address = "127.0.0.1:8500"
    }
    EOF
  }
}