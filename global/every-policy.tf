# reference
# https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy
resource "aws_iam_policy" "force_mfa" {
  name        = "force_mfa"
  description = "This policy allows users to manage their own passwords and MFA devices but nothing else unless they authenticate with MFA."
  policy = data.aws_iam_policy_document.force_mfa.json
}
#### Permission to self managed MFA
#### Force user to use MFA for security issue
# reference
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html
data "aws_iam_policy_document" "force_mfa" {  
  statement {
    sid = "AllowViewAccountInfo"
    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListVirtualMFADevices",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"
    actions = [
      // 본인 패스워드 관리 허용
      "iam:ListUsers",
      "iam:GetUser",
      "iam:ChangePassword",
      // 본인 액세스키 관리 허용
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      // 본인 Signing Certificates 허용
      "iam:ListSigningCertificates",
      "iam:DeleteSigningCertificate",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
      // 본인 SSH 공개키 관리 허용
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
      "iam:DeleteSSHPublicKey",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey",
      // 본인 Service Specific Credential 관리 허용
      "iam:CreateServiceSpecificCredential",
      "iam:DeleteServiceSpecificCredential",
      "iam:ListServiceSpecificCredentials",
      "iam:ResetServiceSpecificCredential",
      "iam:UpdateServiceSpecificCredential",
      // 본인 MFA 관리 허용
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
      "iam:DeactivateMFADevice",
    ]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  // 본인 VirtualMFA 관리 허용
  statement {
    sid = "AllowManageOwnVirtualMFADevice"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]
    resources = ["arn:aws:iam::*:mfa/$${aws:username}"]
  }

  // MFA가 없는경우, 아래의 동작만 수행 가능
  statement {
    sid    = "DenyAllExceptListedIfNoMFA"
    effect = "Deny"
    not_actions = [
      // 비밀번호 변경 가능
      "iam:ListUsers",
      "iam:GetUser",
      "iam:ChangePassword",
      "iam:GetAccountPasswordPolicy",
      "sts:GetSessionToken",
      // VirtualMFA 관리 가능
      "iam:ListVirtualMFADevices",
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      // MFA 관리 가능
      "iam:ListMFADevices",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
    ]
    resources = ["*"]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = [false]
    }
  }
}

# iam policy for terraform cloud
resource "aws_iam_policy" "terraform_cloud" {
  name        = "TerraformCloud"
  description = ""
  policy      = data.aws_iam_policy_document.terraform_cloud.json
}

data "aws_iam_policy_document" "terraform_cloud" {
  statement {
    actions = [
      "autoscaling:*",
      "cloudwatch:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "events:*",
      "iam:*",
      "lambda:*",
      "logs:*",
      "route53:*",
      "route53domains:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "s3:*",
      "tag:GetResources"
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "autoscaling.amazonaws.com",
        # "ec2scheduled.amazonaws.com",
        # "elasticloadbalancing.amazonaws.com",
        "spot.amazonaws.com",
        "spotfleet.amazonaws.com"
      ]
    }
  }
}

# iam policy for s3 access
# resource "aws_iam_policy" "amazon_s3_access" {
#   name        = "AmazonS3Access"
#   description = "Provide Access to Amazon S3 buckets."

#   policy = data.aws_iam_policy_document.amazon_s3_access.json
# }

# data "aws_iam_policy_document" "amazon_s3_access" {
#   statement {
#     actions = ["s3:*"]
#     resources = [
#       "${aws_s3_bucket.ian_uploaded_files.arn}/*",
#       "${aws_s3_bucket.ian_uploaded_files_thumb.arn}/*",
#       "${aws_s3_bucket.ian_uploaded_files_temp.arn}/*",
#       "${aws_s3_bucket.ian_uploaded_files_deleted.arn}/*",
#     ]
#   }

#   statement {
#     actions = [
#       "s3:Get*",
#       "s3:List*"
#     ]
#     resources = [
#       aws_s3_bucket.ian_uploaded_files.arn,
#       aws_s3_bucket.ian_uploaded_files_thumb.arn,
#       aws_s3_bucket.ian_uploaded_files_temp.arn,
#       aws_s3_bucket.ian_uploaded_files_deleted.arn
#     ]
#   }
# }

# iam policy for route53
# resource "aws_iam_policy" "route53" {
#   name        = "Route53Access"
#   description = "Provide Access to route53."

#   policy = data.aws_iam_policy_document.route53.json
# }

# data "aws_iam_policy_document" "route53" {
#   statement {
#     actions = [
#       "sts:AssumeRole",
#     ]
#     resources = ["*"]
#   }

#   statement {
#     actions = [
#       "route53:ListResourceRecordSets",
#       "route53:ChangeResourceRecordSets",
#     ]
#     resources = ["arn:aws:route53:::hostedzone/${aws_route53_zone.ian_ec2.zone_id}"]
#   }

#   statement {
#     actions = [
#       "route53:ListHostedZonesByName",
#     ]
#     resources = ["*"]
#   }

#   statement {
#     actions = [
#       "route53:GetChange",
#     ]
#     resources = ["arn:aws:route53:::change/*"]
#   }
# }
