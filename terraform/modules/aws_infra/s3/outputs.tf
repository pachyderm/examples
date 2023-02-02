output "s3_role_arn" {
    value = aws_iam_role.s3_role.arn
}

output "s3_bucket_id" {
    value = aws_s3_bucket.s3_bucket.id
}