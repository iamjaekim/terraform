resource "aws_db_instance" "database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "mydemoaccount"
  password             = "mysuper$ecurePassw0rdhere!"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.dbsubnetgroup.id}"
}

resource "aws_db_subnet_group" "dbsubnetgroup" {
  subnet_ids = ["${var.priv1subnet}", "${var.priv2subnet}"]
}