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
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # ALBからのみ通す
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

# ALB用SG
resource "aws_security_group" "alb_sg" {
  name   = "myapp-alb-sg"
  vpc_id = aws_vpc.myapp_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
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

# CloudFront 公開鍵の登録
resource "aws_cloudfront_public_key" "example" {
  comment     = "demo-public-key"
  encoded_key = file("public_key.pem")
  name        = "demo-key"
}

# キーグループの作成
resource "aws_cloudfront_key_group" "example" {
  comment = "demo-key-group"
  items   = [aws_cloudfront_public_key.example.id]
  name    = "demo-key-group"
}

# CloudFront ディストリビューション（既存のALBをオリジンに指定）
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_lb.main.dns_name # ALBを向かせる
    origin_id   = "myALBOrigin"

    custom_header {
      name  = "X-Custom-Header"
      value = var.cloudfront_custom_header_value # 合言葉を渡す
    }
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myALBOrigin"
    
    # 署名付きURLを強制
    trusted_key_groups = [aws_cloudfront_key_group.example.id]

    forwarded_values {
      query_string = true
      cookies { forward = "all" }
    }
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions { 
   geo_restriction {
    restriction_type = "none"
    locations        = []
   } 
  }
  viewer_certificate {
    cloudfront_default_certificate = true
 }
}

# ALB側で「合言葉がないリクエスト」を拒否する
resource "aws_lb_listener_rule" "allow_cloudfront_only" {
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