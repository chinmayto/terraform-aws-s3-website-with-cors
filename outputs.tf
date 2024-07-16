output "static_site_endpoint" {
  value = "http://${aws_s3_bucket_website_configuration.static_site_bucket_website_config.website_endpoint}"
}