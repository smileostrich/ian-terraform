output "encrypted_passwords" {
    value = {
        for index, user in var.users:
        user.username => aws_iam_user_login_profile.sysadmins.*.encrypted_password[index]
    }
}