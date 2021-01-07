output "encrypted_passwords" {
    value = {
        for index, user in var.sysadmins:
        user.username => aws_iam_user_login_profile.this.*.encrypted_password[index]
    }
}