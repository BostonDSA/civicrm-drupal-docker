resource "aws_ecr_repository" "default" {
  name = "${var.org_name}"
}
