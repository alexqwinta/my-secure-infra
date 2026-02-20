hcl
# 1. VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "main-vpc" }
}

# 2. S3 Bucket (Приклад з потенційною вразливістю)
resource "aws_s3_bucket" "data" {
  bucket = "my-secure-data-bucket-unique-123"
}

# Блок, що робить bucket приватним (Checkov перевіряє його наявність)
resource "aws_s3_bucket_public_access_block" "data_block" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Security Group (Відкритий 22 порт - ГРІХ!)
resource "aws_security_group" "allow_ssh" {
  name   = "allow_ssh"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Це спровокує помилку в Checkov/tfsec
  }
}

# 4. EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0" # Замініть на актуальний AMI
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = { Name = "Web-Server" }
}

hcl
# 1. Створюємо S3 для логів CloudTrail
resource "aws_s3_bucket" "audit_logs" {
  bucket        = "my-company-audit-logs-unique-id"
  force_destroy = true
}

# 2. Налаштовуємо CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "main-infrastructure-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true # Гарантує, що логи не були змінені
}
