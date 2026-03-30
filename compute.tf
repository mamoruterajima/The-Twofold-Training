# 10. EC2インスタンス本体
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

# 11. ECRリポジトリ（Dockerイメージの保管庫）
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