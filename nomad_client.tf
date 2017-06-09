resource "aws_instance" "nomad_client" {
	count = "${var.servers}"
	ami = "${var.ubuntu_ami}"
	key_name = "${var.key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
	subnet_id = "${module.vpc.public_subnet_cidr}"
	instance_type = "${var.instance_client}"
	vpc_security_group_ids = ["${aws_security_group.nomad_master_server_sg.id}"]

  user_data = "${element(data.template_file.client.*.rendered, count.index)}"

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

data "template_file" "client" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/consul.sh.tpl")}"

  vars {
    consul_version = "0.8.2"
    nomad_version = "0.5.6"

    config = <<EOF
     "node_name": "${var.namespace}-client-${count.index}",
     "retry_join_ec2": {
       "tag_key": "${var.consul_join_tag_key}",
       "tag_value": "${var.consul_join_tag_value}"
     },
     "server": false
    EOF

    nomad_config = <<EOF
    client {
      enabled = true
      options {
        "driver.raw_exec.enable" = "1"
      }
    }

    consul {
      server_service_name = "nomad-server"
      server_auto_join = true
      client_service_name = "nomad-client-${count.index}"
      client_auto_join = true
      auto_advertise = true
      address = "127.0.0.1:8500"
    }
    EOF
  }
}