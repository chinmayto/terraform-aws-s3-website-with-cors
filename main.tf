################################################################################
# S3 static website bucket for html pages
################################################################################
resource "aws_s3_bucket" "my-static-website-html" {
  bucket = var.bucket_name_html
  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-s3-bucket-html"
  })
}

################################################################################
# S3 public access settings
################################################################################
resource "aws_s3_bucket_public_access_block" "static_site_bucket_public_access" {
  bucket = aws_s3_bucket.my-static-website-html.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

################################################################################
# S3 bucket policy
################################################################################
resource "aws_s3_bucket_policy" "static_site_bucket_policy" {
  bucket = var.bucket_name_html

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name_html}",
          "arn:aws:s3:::${var.bucket_name_html}/*"
        ]
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static_site_bucket_public_access]
}


################################################################################
# S3 bucket static website configuration
################################################################################
resource "aws_s3_bucket_website_configuration" "static_site_bucket_website_config" {
  bucket = aws_s3_bucket.my-static-website-html.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

################################################################################
# Upload files to S3 Bucket - html files
################################################################################
resource "aws_s3_object" "provision_source_files" {
  bucket = aws_s3_bucket.my-static-website-html.id

  # webfiles/ is the Directory contains files to be uploaded to S3
  for_each = fileset("webfiles/", "**/*.html*")

  key          = each.value
  source       = "webfiles/${each.value}"
  content_type = "text/html"
  #acl          = "public-read" #use this only if you are using Bucket and Object ACLs, defaults to private
}


################################################################################
# S3 static website bucket for images
################################################################################
resource "aws_s3_bucket" "my-static-website-images" {
  bucket = var.bucket_name_images
  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-s3-bucket-images"
  })
}

################################################################################
# S3 public access settings
################################################################################
resource "aws_s3_bucket_public_access_block" "static_site_bucket_public_access_images" {
  bucket = aws_s3_bucket.my-static-website-images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

################################################################################
# S3 bucket policy
################################################################################
resource "aws_s3_bucket_policy" "static_site_bucket_policy_images" {
  bucket = var.bucket_name_images

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name_images}",
          "arn:aws:s3:::${var.bucket_name_images}/*"
        ]
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static_site_bucket_public_access_images]
}


################################################################################
# S3 bucket static website configuration
################################################################################
resource "aws_s3_bucket_website_configuration" "static_site_bucket_website_config_images" {
  bucket = aws_s3_bucket.my-static-website-images.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

################################################################################
# Upload files to S3 Bucket - html files
################################################################################
resource "aws_s3_object" "provision_image_files" {
  bucket = aws_s3_bucket.my-static-website-images.id

  # webfiles/ is the Directory contains files to be uploaded to S3
  for_each = fileset("webfiles/", "**/*.jpg")

  key          = each.value
  source       = "webfiles/${each.value}"
  content_type = "image/jpg"
  #acl          = "public-read" #use this only if you are using Bucket and Object ACLs, defaults to private
}


################################################################################
# Setup Cross Origin Resource Sharing CORS for Images website
################################################################################
resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.my-static-website-images.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["http://${var.bucket_name_html}.s3-website-us-east-1.amazonaws.com"]
    max_age_seconds = 3000
  }
}
