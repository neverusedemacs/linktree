terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_iam_policy_document" "linktree" {
  version = "2012-10-17"
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${var.aws_bucket}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "linktree" {
  bucket = aws_s3_bucket.assets.bucket
  policy = data.aws_iam_policy_document.linktree.json
}

resource "aws_s3_object" "linktree_html" {
  bucket       = aws_s3_bucket.assets.bucket
  key          = "index.html"
  source       = "source/index.html"
  content_type = "text/html"
  source_hash  = filemd5("source/index.html")
}

resource "aws_s3_object" "linktree_css" {
  bucket       = aws_s3_bucket.assets.bucket
  key          = "style.css"
  source       = "source/style.css"
  content_type = "text/css"
  source_hash  = filemd5("source/style.css")
}

resource "aws_s3_object" "linktree_assets" {
  for_each = fileset(path.module, "source/assets/*")
  bucket = aws_s3_bucket.assets.bucket
  key    = trim(each.value, "source/")
  source_hash = filemd5(each.value)
}

resource "aws_s3_bucket" "assets" {
  bucket = var.aws_bucket
  tags = {
    deployed_with_terraform = true
    deployed_from_github    = true
    description             = "linktree s3 bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "linktree" {
  bucket = aws_s3_bucket.assets.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "linktree" {
  bucket = aws_s3_bucket.assets.bucket

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = [aws_s3_bucket.assets.website_endpoint]

  }
}

resource "aws_s3_bucket_acl" "linktree_acl" {
  bucket = aws_s3_bucket.assets.bucket
  acl    = "public-read"
}