resource "aws_db_instance" "job_postings" {
  identifier           = "job-postings"
  db_name              = "job_postings"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  username             = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password             = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name

  tags = {
    Name = "job_postings"
  }
}