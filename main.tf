provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {}

# AWS Resources
resource "aws_s3_bucket" "site" {
  bucket = var.site_domain
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_acl" "site" {
  bucket = aws_s3_bucket.site.id
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*"
        ]
      }
    ]
  })
}

# Cloudflare Resources
data "cloudflare_zones" "domain" {
  filter {
    name = var.site_domain
  }
}

resource "cloudflare_record" "site_cname" {
  name    = var.site_domain
  type    = "CNAME"
  zone_id = data.cloudflare_zones.domain.zones[0].id
  value = aws_s3_bucket_website_configuration.site.website_endpoint
  ttl = 1
  proxied = true
}

resource "cloudflare_record" "www" {
  name    = "www"
  type    = "CNAME"
  zone_id = data.cloudflare_zones.domain.zones[0].id
  value = var.site_domain
  ttl = 1
  proxied = true
}