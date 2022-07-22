locals {
  source_s3_directory = abspath("${path.module}/../../dev_data/SOURCE_S3/")
}


resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "unity-sps-dev"
  force_destroy = true
  #   tags = {
  #     Name        = "My bucket"
  #     Environment = "Dev"
  #   }
}
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "source_files" {
  for_each = fileset(local.source_s3_directory, "**/*.*")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = each.value
  source   = "${local.source_s3_directory}/${each.value}"
  etag     = filemd5("${local.source_s3_directory}/${each.value}")
}
