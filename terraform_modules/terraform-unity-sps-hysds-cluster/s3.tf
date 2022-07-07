locals {
  source_s3_directory = abspath("${path.module}/../../dev_data/SOURCE_S3/sounder_sips")
}


resource "aws_s3_bucket" "sps_s3_bucket" {
  bucket = "unity-sps-dev"
  #   tags = {
  #     Name        = "My bucket"
  #     Environment = "Dev"
  #   }
}
resource "aws_s3_bucket_acl" "sps_s3_bucket_acl" {
  bucket = aws_s3_bucket.sps_s3_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "object1" {
  for_each = fileset(local.source_s3_directory, "**/*.*")
  bucket   = aws_s3_bucket.sps_s3_bucket.id
  key      = each.value
  source   = "${local.source_s3_directory}/${each.value}"
  etag     = filemd5("${local.source_s3_directory}/${each.value}")
}
