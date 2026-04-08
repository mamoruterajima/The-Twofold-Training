variable "my_ip" {
  description = "ローカルのIPアドレスを入力してください" # apply実行時に直接入力で指定
  type        = string
}

variable "alert_email_address" {
  description = "アラートメールの送信先アドレスを入力してください" # アドレスもアプライ時に入力
  type        = string
}

variable "cloudfront_custom_header_value" {
  description = "ALBからCloudFrontへの認証のためのシークレットヘッダー値を入力してください"
  type        = string
  sensitive   = true # 実行時のログに値が表示しない
}

variable "db_password" {
  description = "DBのパスワードを入力してください" # アドレスもアプライ時に入力
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS Account ID (12 digits)"
  type        = string
}

variable "rails_master_key" {
  description = "Rails Master Key"
  type        = string
  sensitive   = true # ログに出力されないように設定
}