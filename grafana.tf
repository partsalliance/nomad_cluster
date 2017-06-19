resource "aws_instance" "grafana" {
	ami = "${var.ubuntu_ami}"
	key_name = "${var.key_pair}"
	subnet_id = "${module.vpc.public_subnet_cidr}"
	instance_type = "${var.instance_client}"
	vpc_security_group_ids = ["${aws_security_group.nomad_master_server_sg.id}"]
	user_data = "${data.template_file.prometheus.rendered}"
}

data "template_file" "grafana" {
  template = "${file("${path.module}/templates/grafana.sh.tpl")}"
}