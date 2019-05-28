# Setting this up anticpating sharing the instance between
# multiple applications.

resource "aws_db_instance" "shared" {
  allocated_storage = 20
  availability_zone = "${var.aws_availability_zone}"
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t3.micro"
  identifier = "${var.org_name}"
  name = "${var.org_name}"
  username = "${var.org_name}"
  # TODO I couldn't find how to link the terraform secrets manager
  # to the RDS instance like you can in the UI. Manually manage the secret
  # for now.
  password = "{$var.aws_rds_root_password}"
  parameter_group_name = "default.mysql5.7"
  storage_encrypted = true
  # skip_final_snapshot = true
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
}
