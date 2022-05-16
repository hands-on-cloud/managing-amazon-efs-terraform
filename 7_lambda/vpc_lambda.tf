locals {
  resource_name_prefix                = "${local.prefix}-lambda"
  lambda_code_path                    = "${path.module}/lambdas/vpc_lambda"
  lambda_archive_path                 = "${path.module}/lambdas/vpc_lambda.zip"
  lambda_handler                      = "index.lambda_handler"
  lambda_description                  = "This is VPC Lambda function"
  lambda_runtime                      = "python3.9"
  lambda_timeout                      = 5
  lambda_concurrent_executions        = -1
  lambda_cw_log_group_name            = "/aws/lambda/${aws_lambda_function.vpc_lambda.function_name}"
  lambda_log_retention_in_days        = 1
  lambda_managed_policy_arns          = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  lambda_file_system_local_mount_path = "/mnt/efs"
}

data "archive_file" "vpc_lambda_zip" {
  source_dir = local.lambda_code_path
  output_path = local.lambda_archive_path
  type = "zip"
}

data "aws_iam_policy_document" "vpc_lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "vpc_lambda_list_s3_buckets" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "vpc_lambda_custom_policy" {
  policy = data.aws_iam_policy_document.vpc_lambda_list_s3_buckets.json
}

data "aws_iam_policy" "vpc_lambda" {
  for_each = toset(local.lambda_managed_policy_arns)
  arn = each.value
}

resource "aws_iam_role_policy_attachment" "vpc_lambda" {
  for_each = data.aws_iam_policy.vpc_lambda
  role       = local.iam_lambda_role_name
  policy_arn = each.value.arn
}

resource "aws_iam_role_policy_attachment" "vpc_lambda_custom_policy" {
  role       = local.iam_lambda_role_name
  policy_arn = aws_iam_policy.vpc_lambda_custom_policy.arn
}

data "aws_iam_role" "vpc_lambda" {
  name = local.iam_lambda_role_name
}

resource "aws_security_group" "vpc_lambda" {
  name        = "${local.resource_name_prefix}-sg"
  description = "Allow outbound traffic for ${local.resource_name_prefix}-lambda"
  vpc_id      = local.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {
      Name = local.resource_name_prefix
    },
    local.common_tags
  )
}

resource "aws_lambda_function" "vpc_lambda" {
  function_name     = local.resource_name_prefix
  source_code_hash  = data.archive_file.vpc_lambda_zip.output_base64sha256
  filename          = data.archive_file.vpc_lambda_zip.output_path
  description       = local.lambda_description
  role              = data.aws_iam_role.vpc_lambda.arn
  handler           = local.lambda_handler
  runtime           = local.lambda_runtime
  timeout           = local.lambda_timeout

  vpc_config {
    security_group_ids = [aws_security_group.vpc_lambda.id]
    subnet_ids         = local.private_subnets
  }

  file_system_config {
    arn               = local.efs_ap_lambda_arn
    local_mount_path  = local.lambda_file_system_local_mount_path
  }

  environment {
    variables = {
      EFS_MOUNT_POINT = local.lambda_file_system_local_mount_path
    }
  }

  tags = merge(
    {
      Name = local.resource_name_prefix
    },
    local.common_tags
  )

  reserved_concurrent_executions = local.lambda_concurrent_executions
}

# CloudWatch Log Group for the Lambda function
resource "aws_cloudwatch_log_group" "vpc_lambda" {
  name = local.lambda_cw_log_group_name
  retention_in_days = local.lambda_log_retention_in_days
}
