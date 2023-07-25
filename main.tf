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

#  tags = merge(
#   local.tags,
#   {
#    name = "github-actions-provider"
#   }
#  )
}
#1

# data "aws_iam_role" "example" {
#   name = "s3_full"
# }
# resource "aws_iam_role" "test_role" {
#   name = "GitHub_role"
#   #id = data.aws_iam_role.example.id

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Federated": "arn:aws:iam::528267078178:oidc-provider/token.actions.githubusercontent.com"
#             },
#             "Action": "sts:AssumeRoleWithWebIdentity",
#             "Condition": {
#                 "StringEquals": {
#                     "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
#                     "token.actions.githubusercontent.com:sub": "repo:Rahul-Palande11/GithubActions-website:ref:refs/heads/main"
#                 }
#             }
#         }
#     ]

# }
# EOF

#   tags = {
#     tag-key = "GitHub"
#   }
# }

# resource "aws_iam_role_policy_attachment" "test_role_attachment_2" {
#   policy_name = "MyInlinePolicy"   # Name for the inline policy
#   role        = aws_iam_role.test_role.name

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:*",
#                 "s3-object-lambda:*"
#             ],
#             "Resource": "*"
#         }
#     ]
#   })
# }
