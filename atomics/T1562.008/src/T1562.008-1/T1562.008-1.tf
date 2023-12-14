terraform {
  required_version = ">= 0.12"
}

provider "aws" {
}

variable "cloudtrail_name" {
}

variable "s3_bucket_name" {
}

variable "region" {
}

resource "aws_s3_bucket" "some_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}


resource "aws_s3_bucket" "some_bucket_log_bucket" {
  bucket = "some_bucket-log-bucket"
}

resource "aws_s3_bucket_logging" "some_bucket" {
  bucket = aws_s3_bucket.some_bucket.id

  target_bucket = aws_s3_bucket.some_bucket_log_bucket.id
  target_prefix = "log/"
}


resource "aws_s3_bucket_policy" "some_policy" {
  bucket = aws_s3_bucket.some_bucket.id
  policy = templatefile("policy.json", {
    cloudtrail_name = "${var.cloudtrail_name}"
    s3_bucket_name  = "${var.s3_bucket_name}"
    region          = "${var.region}"
  })
}

resource "aws_cloudtrail" "some_cloudtrail" {
  s3_bucket_name = aws_s3_bucket.some_bucket.id
  name           = var.cloudtrail_name
  enable_log_file_validation = true
  is_multi_region_trail = true
}