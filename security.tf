# EC2用SG
resource "aws_security_group" "ec2_sg" {
  name        = "myapp-ec2-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.myapp_vpc.id

  # HTTP (80): ブラウザからの標準アクセス
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rails (3000): 直接起動確認用
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (22): 管理用
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # Egress: 外へ通信
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "myapp-ec2-sg" }
}

# DB用SG
resource "aws_security_group" "db_sg" {
  name        = "myapp-db-sg"
  description = "Allow DB traffic from EC2 only"
  vpc_id      = aws_vpc.myapp_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    # CIDRではなくソースに「EC2用SGのID」を直接指定
    # これでEC2インスタンスからのみ接続可能
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # DBから外に通信する必要は基本ないのでegressは最小限
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "myapp-db-sg" }
}