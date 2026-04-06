# IAMロール本体の作成
resource "aws_iam_role" "ec2_role" {
  name = "myapp-ec2-role-v2"

  # EC2への定義
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# ECR読み取り権限のアタッチ
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# SSM操作権限のアタッチ
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2にアタッチ用インスタンスプロフィール
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "myapp-ec2-instance-profile-v2"
  role = aws_iam_role.ec2_role.name
}