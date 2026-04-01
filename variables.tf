variable "my_ip" {
  description = "My local machine public IP address" # apply実行時に直接入力で指定
  type        = string
}

variable "alert_email_address" {
  description = "The email address to receive CloudWatch alerts" # アドレスもアプライ時に入力
  type        = string
}