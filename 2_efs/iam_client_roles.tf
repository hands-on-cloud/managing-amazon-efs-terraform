# EC2 instance IAM role

data "aws_iam_policy_document" "ec2_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${local.prefix}-ec2"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.ec2_role.json
}

# Fargate task IAM role

data "aws_iam_policy_document" "fargate_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "fargate_role" {
  name = "${local.prefix}-fargate"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.fargate_role.json
}

# Lambda IAM role

data "aws_iam_policy_document" "lambda_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-lambda"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}
