# EC2インスタンス本体
resource "aws_instance" "myapp-ec2-instance" {
  ami           = "ami-0b4a1b07f9ca13717" # Amazon Linux 2023
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  
  key_name      = "myapp-key" 

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "myapp-ec2-instance"
  }
}

# ECRリポジトリ（Dockerイメージの保管庫）
resource "aws_ecr_repository" "myapp_repo" {
  name                 = "myapp-repository"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true # プッシュ時に脆弱性スキャンを自動実行
  }
}

# 古いイメージを自動削除する設定（ストレージ代の節約）
resource "aws_ecr_lifecycle_policy" "myapp_repo_policy" {
  repository = aws_ecr_repository.myapp_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 5 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

# ALB本体
resource "aws_lb" "main" {
  name               = "myapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.db_subnet_c.id] # 2つのAZが必要
}

# ターゲットグループ（EC2のポート3000へ流す）
resource "aws_lb_target_group" "main" {
  name     = "myapp-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.myapp_vpc.id
  health_check { path = "/" }
}

# ALBリスナー（ここで「合言葉」を確認する）
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied: Invalid Header"
      status_code  = "403"
    }
  }
}

# 合言葉が一致した時だけEC2へ流すルール
resource "aws_lb_listener_rule" "allow_cloudfront" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = [var.cloudfront_custom_header_value]
    }
  }
}

# EC2とターゲットグループの紐付け
resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.myapp-ec2-instance.id
  port             = 3000
}