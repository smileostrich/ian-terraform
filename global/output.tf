output "encrypted_passwords" {
    description = "the encrypted password, base 64 encoded"
    value = {
        for index, user in var.sysadmins:
        user.username => aws_iam_user_login_profile.sysadmins.*.encrypted_password[index]
    }
}