locals {
  sysadmins = {
    ilmin = {
      name       = "문일민"
      keybase_id = "happyostrich"
    }
    testuser1 = {
      name       = "테스트유저1"
      keybase_id = "user_test1"
    }
  }
}

resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = true
  minimum_password_length        = 14
}

resource "aws_iam_group" "sysadmins" {
  name = "sysadmins"
  path = "/sysadmins/"
}

resource "aws_iam_group_policy_attachment" "sysadmins" {
  group      = aws_iam_group.sysadmins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "sysadmins" {
  for_each = local.sysadmins

  name = each.key
  path = "/sysadmins/"

  tags = {
    Name = each.value.name
  }
}

# reference
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile
resource "aws_iam_user_login_profile" "sysadmins" {
  for_each = local.sysadmins

  user    = each.key
  pgp_key = "keybase:${each.value.keybase_id}"
}

resource "aws_iam_user_group_membership" "sysadmins" {
  for_each = local.sysadmins

  user   = each.key
  groups = [aws_iam_group.sysadmins.name]
}

resource "aws_iam_access_key" "sysadmins" {
  for_each = local.sysadmins

  user    = each.key
  pgp_key = "keybase:${each.value.keybase_id}"
}

locals {
  iam_secrets = {
    for key in aws_iam_access_key.sysadmins :
    key.user => {
      aws_access_key_id               = key.id,
      encrypted_aws_secret_access_key = key.encrypted_secret
      encrypted_initial_password      = aws_iam_user_login_profile.sysadmins[key.user].encrypted_password
    }
  }
}





#
# IAM Users
#
# resource "aws_iam_user" "programmatic_users" {
#   for_each = toset(local.programmatic_users)
#   name     = each.key
# }

# resource "aws_iam_user_policy_attachment" "terraform_cloud" {
#   user       = "terraform-cloud"
#   policy_arn = aws_iam_policy.terraform_cloud.arn
# }



#
# IAM Groups
#
# resource "aws_iam_group" "sysadmins" {
#   name = "sysadmins"
#   path = "/sysadmins/"
# }
# resource "aws_iam_group_policy_attachment" "admin_permission" {
#   group      = aws_iam_group.admin.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # AWS managed policy
# }

# resource "aws_iam_group_policy_attachment" "admin_mfa" {
#   group      = aws_iam_group.admin.name
#   policy_arn = aws_iam_policy.force_mfa.arn
# }

# resource "aws_iam_group" "readonly" {
#   name = "ReadOnly"
# }

# resource "aws_iam_group_policy_attachment" "readonly_permission" {
#   group      = aws_iam_group.readonly.name
#   policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # AWS managed policy
# }

# resource "aws_iam_group_policy_attachment" "readonly_mfa" {
#   group      = aws_iam_group.readonly.name
#   policy_arn = aws_iam_policy.force_mfa.arn
# }


#
# IAM Roles
#
# resource "aws_iam_role" "ian_homepage" {
#   name               = "ian-homepage"
#   description        = "Allows EC2 instances to call AWS services on your behalf."
#   assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
# }

# data "aws_iam_policy_document" "instance_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_instance_profile" "ian_homepage" {
#   name = "ian-homepage"
#   role = aws_iam_role.ian_homepage.name
# }

# resource "aws_iam_role_policy_attachment" "ian_homepage_amazon_s3_access" {
#   role       = aws_iam_role.ian_homepage.name
#   policy_arn = aws_iam_policy.amazon_s3_access.arn
# }

# resource "aws_iam_role_policy_attachment" "ian_homepage_route53" {
#   role       = aws_iam_role.ian_homepage.name
#   policy_arn = aws_iam_policy.route53.arn
# }