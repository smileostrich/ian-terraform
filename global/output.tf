output "encrypted_aws_iam_secrets" {
    description = "the encrypted password, base 64 encoded"
    value = {
        for key in aws_iam_access_key.sysadmins :
        key.user => {
        aws_access_key_id               = key.id,
        encrypted_aws_secret_access_key = key.encrypted_secret
        encrypted_initial_password      = aws_iam_user_login_profile.sysadmins[key.user].encrypted_password
    }
  }
}