resource "aws_default_vpc" "default" {}
resource "aws_default_subnet" "default" {
  availability_zone = "${var.aws_availability_zone}"
}

resource "aws_security_group" "civicrm" {
  name        = "${var.project_name}-web"
  description = "Allow web traffic"
  vpc_id      = "${aws_default_vpc.default.id}"

  # TODO adding this to aid in debugging
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-database"
  description = "Allow database traffic"
  vpc_id      = "${aws_default_vpc.default.id}"

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.civicrm.id}"]
  }

}
