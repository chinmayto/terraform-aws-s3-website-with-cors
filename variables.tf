variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
  default     = "us-east-1"
}

variable "bucket_name_html" {
  type        = string
  description = "Name of the S3 Bucket for HTML pages"
  default     = "my-s3-static-bucket-html-v1"
}

variable "bucket_name_images" {
  type        = string
  description = "Name of the S3 Bucket for Images"
  default     = "my-s3-static-bucket-images-v1"
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "CT"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
  default     = "Project"
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all resources."
  default     = "Demo"
}

variable "environment" {
  type        = string
  description = "Environment for deployment"
  default     = "dev"
}

variable "instance_key" {
  default = "WorkshopKeyPair"
}