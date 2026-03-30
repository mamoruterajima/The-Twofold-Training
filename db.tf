resource "aws_subnet" "db_subnet_a" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"
  tags = { Name = "myapp-db-subnet-a" }
}

resource "aws_subnet" "db_subnet_c" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-1c"
  tags = { Name = "myapp-db-subnet-c" }
}

resource "aws_db_subnet_group" "db_sg" {
  name       = "myapp-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_a.id, aws_subnet.db_subnet_c.id]
}

resource "aws_db_instance" "myapp_db" {
  identifier           = "myapp-db-instance"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # 無料枠
  db_name              = "myapp_production"
  username             = "admin"
  password             = "password123"
  skip_final_snapshot  = true　# 容量削減のためスナップショットは取らない
  db_subnet_group_name = aws_db_subnet_group.db_sg.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}