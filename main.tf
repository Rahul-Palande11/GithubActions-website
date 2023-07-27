locals {
  github_token_url="https://token.actions.githubusercontent.com"
}

data "tls_certificate" "example" {
 url = "https://token.actions.githubusercontent.com"
}



resource "aws_iam_openid_connect_provider" "iam_oidc_connect_provider_data" {
 url = local.github_token_url
 client_id_list = ["sts.amazonaws.com"]
 thumbprint_list = [data.tls_certificate.example.certificates[0].sha1_fingerprint]
}
#1

# data "aws_iam_role" "example" {
#   name = "s3_full"
# }
# resource "aws_iam_role" "test_role" {
#   name = "GitHub_role"

#   assume_role_policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "Federated": "arn:aws:iam::528267078178:oidc-provider/token.actions.githubusercontent.com"
#         },
#         "Action": "sts:AssumeRoleWithWebIdentity",
#         "Condition": {
#           "StringEquals": {
#             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
#             "token.actions.githubusercontent.com:sub": "repo:Rahul-Palande11/GithubActions-website:ref:refs/heads/main"
#           }
#         }
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "s3:*",
#           "s3-object-lambda:*"
#         ],
#         "Resource": "*"
#       }
#     ]
#   })

#   tags = {
#     "tag-key" = "GitHub"
#   }
# }

resource "aws_iam_role" "test_role" {
  name = "GitHub_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::528267078178:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub": "repo:Rahul-Palande11/GithubActions-website:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    "tag-key" = "GitHub"
  }
}
#528267078178
# data "aws_iam_policy" "my-policy" {
#   name = "AmazonS3FullAccess"
# }

# resource "aws_iam_role_policy" "test_role_policy" {
#   name   = "AWSs3FullAccess"
#   role   = aws_iam_role.test_role.id
#  policy  = data.aws_iam_policy.my-policy
 
# }
data "aws_iam_policy" "my-policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_policy_attachment" "test_role_attachment" {
  name       = "AWSs3FullAccessAttachment"
  roles      = [aws_iam_role.test_role.name]
  policy_arn = data.aws_iam_policy.my-policy.arn
}




# S3 Bucket
resource "aws_s3_bucket" "my-bucket" {
  bucket = "my-static-website-1996"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_cloudfront_distribution" "my-cloudfront-distribution" {
  origin {
    domain_name = aws_s3_bucket.my-bucket.bucket_regional_domain_name
    origin_id   = "my-s3-origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.my-oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "simpleWebsite.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my-s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "My CloudFront Distribution"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "my-oai" {
  comment = "My Origin Access Identity"
}

resource "aws_s3_bucket_policy" "my-bucket-policy" {
  bucket = aws_s3_bucket.my-bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "MyPolicy",
    Statement = [
      {
        Sid       = "GrantCloudFrontAccess",
        Effect    = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.my-oai.iam_arn
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my-bucket.arn}/*"
      }
    ]
  })
}





