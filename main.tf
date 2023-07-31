locals {
  github_repo = "Rahul-Palande11/GithubActions-website"
}

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
            "token.actions.githubusercontent.com:sub": "repo:${local.github_repo}:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    "tag-key" = "GitHub"
  }
}

resource "aws_iam_policy" "test_policy" {
  name        = "MyGitHubActionsPolicy"
  description = "Policy for GitHub Actions"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowListBucket",
        "Effect": "Allow",
        "Action": "s3:ListBucket",
        "Resource": "arn:aws:s3:::my-static-website-1996"
      },
      {
        "Sid": "AllowGetObject",
        "Effect": "Allow",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::my-static-website-1996/*"
      },
      {
        "Sid": "AllowPutObject",
        "Effect": "Allow",
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::my-static-website-1996/*"
      },
      {
        "Sid": "ECSPermissions",
        "Effect": "Allow",
        "Action": [
          "ecs:RunTask",
          "ecs:StopTask"
        ],
        "Resource": "*"
      },
      {
        "Sid": "ECRPermissions",
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:PutImage"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test_policy_attachment" {
  policy_arn = aws_iam_policy.test_policy.arn
  role       = aws_iam_role.test_role.name
}

resource "aws_s3_bucket" "my-bucket" {
  bucket = "my-static-website-1996"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
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
          AWS = aws_iam_role.test_role.arn
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my-bucket.arn}/*"
      }
    ]
  })
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
