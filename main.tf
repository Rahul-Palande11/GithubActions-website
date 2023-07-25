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