output "aws_iam_sysadmin_arn" {
  value = aws_iam_user.sysadmins.*.arn
}

output "aws_iam_programmatic_arn" {
  value = aws_iam_user.programmatic_users.*.arn
}