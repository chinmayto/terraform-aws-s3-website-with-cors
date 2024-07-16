# Implementing Cross-Origin Resource Sharing (CORS) with Terraform and AWS S3
Implementing Cross-Origin Resource Sharing (CORS) with Terraform and AWS S3

In this technical blog post, we will explore how to set up Cross-Origin Resource Sharing (CORS) for AWS S3 buckets using Terraform. CORS is essential for allowing web applications to make requests to a domain that is different from the one serving the web page, enabling secure and controlled data sharing across origins.

## Architecture Overview
Before diving into the implementation details, let's outline the architecture we will be working with:

![alt text](/images/diagram.png)

## Step 1: Create S3 Bucket with HTML Pages
We will create an Amazon S3 bucket that hosts our HTML pages. These pages will  fetch resources (like images) from other S3 buckets , demonstrating the need for CORS.

```terraform
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

```

## Step 2: Create S3 Bucket with Images
Additionally, we will set up another S3 bucket dedicated to hosting images. These images are static assets that our web pages hosted in the first S3 bucket will request.
```terraform
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

```

## Step 3: CORS Configuration
 This involves specifying which origins (domains) are allowed to access resources in our images S3 buckets.

```terraform
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
```

### Steps to Run Terraform
Follow these steps to execute the Terraform configuration:
```terraform
terraform init
terraform plan 
terraform apply -auto-approve
```

Upon successful completion, Terraform will provide relevant outputs.
```terraform
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

static_site_endpoint = "http://my-s3-static-bucket-html-v1.s3-website-us-east-1.amazonaws.com"
```

## Testing
S3 buckets
![alt text](/images/buckets.png)

S3 Static Website:
![alt text](/images/website.png)

CORS details showing image loaded from CORS enabled S3 bucket

![alt text](/images/corsdetails.png)

## Cleanup
Remember to stop AWS components to avoid large bills.
```terraform
terraform destroy -auto-approve
```

## Conclusion
In conclusion, leveraging Terraform to automate the setup of CORS in AWS S3 buckets allows for efficient and repeatable management of cross-origin resource sharing policies. By following the steps outlined in this post and utilizing the provided resources, you can ensure secure and controlled data sharing across different origins in your web applications.

Happy Coding!

## Resources
CORS: https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/cors.html

Github Link: https://github.com/chinmayto/terraform-aws-s3-website-with-cors