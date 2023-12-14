resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name
}
 
#ownership control

resource "aws_s3_bucket_ownership_controls" "control" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
#public access block
resource "aws_s3_bucket_public_access_block" "access" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#ACL
resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.control,
    aws_s3_bucket_public_access_block.access,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

#s3 object to copy index and error to s3

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/read"
}


#website hosting configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id 
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
depends_on = [ aws_s3_bucket_acl.acl ]
}
