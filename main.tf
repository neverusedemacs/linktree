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
    condition {
      test = "IpAddress"
      values = [
        "173.245.48.0/20",
        "103.21.244.0/22",
        "103.22.200.0/22",
        "103.31.4.0/22",
        "141.101.64.0/18",
        "108.162.192.0/18",
        "190.93.240.0/20",
        "188.114.96.0/20",
        "197.234.240.0/22",
        "198.41.128.0/17",
        "162.158.0.0/15",
        "104.16.0.0/13",
        "104.24.0.0/14",
        "172.64.0.0/13",
        "131.0.72.0/22"
      ]
      variable = "aws:SourceIp"
    }
  }
}

resource "aws_s3_bucket_policy" "linktree" {
  bucket = aws_s3_bucket.assets.bucket
  policy = data.aws_iam_policy_document.linktree.json
}

resource "aws_s3_object" "linktree_html" {
  bucket       = aws_s3_bucket.assets.bucket
  key          = "index.html"
  source       = "k/index.html"
  content_type = "text/html"
  source_hash  = filemd5("k/index.html")
}

resource "aws_s3_object" "linktree_css" {
  bucket       = aws_s3_bucket.assets.bucket
  key          = "style.css"
  source       = "k/style.css"
  content_type = "text/css"
  source_hash  = filemd5("k/style.css")
}

resource "aws_s3_object" "linktree_assets" {
  for_each    = fileset(path.module, "k/assets/*")
  source      = each.value
  bucket      = aws_s3_bucket.assets.bucket
  key         = trim(each.value, "k/")
  source_hash = filemd5(each.value)
  content_type = lookup(
    {
      "png"         = "image/png",
      "ico"         = "image/x-icon"
      "webmanifest" = "text/plain"
    },
    split(".", each.value)[1],
  "text/plain")
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
    allowed_headers = [
      "Authorization",
      "Content-Length"
    ]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_acl" "linktree_acl" {
  bucket = aws_s3_bucket.assets.bucket
  acl    = "public-read"
}