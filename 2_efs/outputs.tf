output "efs_id" {
  value = aws_efs_file_system.shared_efs.id
  description = "EFS file system ID"
}

output "efs_arn" {
  value = aws_efs_file_system.shared_efs.arn
  description = "EFS file system ARN"
}

output "efs_dns_name" {
  value = aws_efs_file_system.shared_efs.dns_name
  description = "EFS file system DNS name"
}

output "efs_ap_fargate_id" {
  value       = aws_efs_access_point.fargate.id
  description = "EFS access point ID for Fargete tasks"
}

output "efs_ap_lambda_id" {
  value       = aws_efs_access_point.lambda.id
  description = "EFS access point ID for Lambda functions"
}

output "efs_ap_fargate_arn" {
  value       = aws_efs_access_point.fargate.arn
  description = "EFS access point ARN for Fargete tasks"
}

output "efs_ap_lambda_arn" {
  value       = aws_efs_access_point.lambda.arn
  description = "EFS access point ARN for Lambda functions"
}

output "iam_ec2_role_name" {
  value = aws_iam_role.ec2_role.name
  description = "IAM role name for EC2 instances"
}

output "iam_fargate_role_name" {
  value = aws_iam_role.fargate_role.name
  description = "IAM role name for Fargate tasks"
}

output "iam_lambda_role_name" {
  value = aws_iam_role.lambda_role.name
  description = "IAM role name for Lambda functions"
}

output "iam_ec2_role_arn" {
  value = aws_iam_role.ec2_role.arn
  description = "IAM role ARN for EC2 instances"
}

output "iam_fargate_role_arn" {
  value = aws_iam_role.fargate_role.arn
  description = "IAM role ARN for Fargate tasks"
}

output "iam_lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
  description = "IAM role ARN for Lambda functions"
}
