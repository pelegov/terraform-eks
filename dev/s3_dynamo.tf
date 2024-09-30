resource "aws_s3_bucket" "terraform_state" {
  bucket = "bucket-name"
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"
}