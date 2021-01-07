output "password" {
    value = "${aws_iam_user_login_profile.happyostrich.encrypted_password}"
}