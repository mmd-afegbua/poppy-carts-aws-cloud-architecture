output "s3_bucket_arn" {
    description = "Amazon Resource Name for s3 backend"
    value = aws_s3_bucket.terraform_state.arn
}

output "dynamo_table_name" {
    description = "Name of DB that locks the state"
    value = aws_dynamodb_table.terraform_locks.name
}