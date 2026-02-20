hcl
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test" # Для LocalStack можна будь-які
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://localhost:4566" # Якщо запускаєте terraform локально
  }
}

resource "aws_s3_bucket" "local_bucket" {
  bucket = "my-local-test-bucket"
}
