provider "aws" {
  region = "${var.aws_region}"
}

# ECS

resource "aws_ecs_cluster" "civicrm" {
  name = "${var.project_name}"
}

resource "aws_ecs_service" "civicrm" {
  name            = "${var.project_name}"
  cluster         = "${aws_ecs_cluster.civicrm.id}"
  task_definition = "${aws_ecs_task_definition.civicrm.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs"]

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${var.aws_region}]"
  }
}

data "template_file" "container_definitions" {
  template = "${file("civicrm_task.json")}"
  vars {
    aws_account_id = "${var.aws_account_id}"
    aws_region = "${var.aws_region}"
    project_name = "${var.project_name}"
    org_name = "${var.org_name}"
    # TODO move this out of env vars
    mysql_password = "${var.aws_rds_root_password}"
    mysql_host = "${aws_db_instance.shared.address}"
    # TODO move this out of env vars
    drupal_hash_salt = "${var.drupal_hash_salt}"
    base_url = "${var.base_url}"
  }
}

resource "aws_ecs_task_definition" "civicrm" {
  family = "${var.project_name}"
  requires_compatibilities = ["EC2"]
  container_definitions = "${data.template_file.container_definitions.rendered}"

  volume {
    name      = "letsencrypt"
    host_path = "/etc/letsencrypt/local"
  }
}

data "aws_ami" "amazon-linux-ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.????????-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  #"${data.aws_ami.amazon-linux-ecs.id}"
  ami           = "ami-00cf4737e238866a3"
  instance_type = "t3.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ec2.name}"
  subnet_id = "${aws_default_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.civicrm.id}"]
  # This is a pregenerted key
  key_name = "civicrm"

  tags = {
    Name = "${var.project_name}"
  }

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.civicrm.name} >> /etc/ecs/ecs.config
EOF

}
