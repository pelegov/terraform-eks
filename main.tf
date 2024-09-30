resource "aws_s3_bucket" "terraform_state" {
  bucket = "bucket-name-${terraform.workspace}"
  acl    = "private"

  versioning {
    enabled = true
  }
  tags = {
    Name        = "Terraform State Bucket"
    Environment = terraform.workspace
  }
}