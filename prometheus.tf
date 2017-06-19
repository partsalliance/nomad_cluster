resource "aws_instance" "prometheus" {
	ami = "${var.ubuntu_ami}"
	key_name = "${var.key_pair}"
	subnet_id = "${module.vpc.public_subnet_cidr}"
	instance_type = "${var.instance_client}"
	iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
	vpc_security_group_ids = ["${aws_security_group.nomad_master_server_sg.id}"]
	user_data = "${data.template_file.prometheus.rendered}"
}

data "template_file" "prometheus" {
  template = "${file("${path.module}/templates/prometheus.sh.tpl")}"
}