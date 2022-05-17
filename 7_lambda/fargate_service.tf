locals {
  service_name = "amazon-efs-terraform-flask-demo-app"
  task_image = "${local.container_repository_url}:latest"
  service_port = 80
  container_definition = [{
    cpu         = 512
    image       = local.task_image
    memory      = 1024
    name        = local.service_name
    networkMode = "awsvpc"
    environment = [
      {
        "name": "EFS_MOUNT_POINT", "value": local.container_file_system_local_mount_path
      }
    ]
    portMappings = [
      {
        protocol      = "tcp"
        containerPort = local.service_port
        hostPort      = local.service_port
      }
    ]
    logConfiguration = {
      logdriver = "awslogs"
      options = {
        "awslogs-group"         = local.cw_log_group
        "awslogs-region"        = local.aws_region
        "awslogs-stream-prefix" = "stdout"
      }
    }
    mountPoints = [
      {
        "sourceVolume"  = "efs_volume",
        "containerPath" = local.container_file_system_local_mount_path,
        "readOnly"      = false
      }
    ]
  }]
  cw_log_group = "/ecs/${local.service_name}"
}

# Fargate Service

resource "aws_security_group" "fargate_task" {
  name   = "${local.service_name}-fargate-task"
  vpc_id = local.vpc_id

  ingress {
    from_port   = local.service_port
    to_port     = local.service_port
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.service_name
    }
  )
}

data "aws_iam_policy_document" "fargate-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "fargate_execution" {
  name   = "${local.prefix}-fargate-execution-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetAuthorizationToken",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "fargate_task" {
  name   = "${local.prefix}-fargate-task-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "fargate_execution" {
  name               = "${local.prefix}-fargate-execution-role"
  assume_role_policy = data.aws_iam_policy_document.fargate-role-policy.json
}

resource "aws_iam_role_policy_attachment" "fargate_execution" {
  role       = aws_iam_role.fargate_execution.name
  policy_arn = aws_iam_policy.fargate_execution.arn
}

resource "aws_iam_role_policy_attachment" "fargate_task" {
  role       = local.iam_fargate_role_name
  policy_arn = aws_iam_policy.fargate_task.arn
}

# Fargate Container
resource "aws_cloudwatch_log_group" "fargate_task" {
  name = local.cw_log_group
  tags = merge(
    local.common_tags,
    {
      Name = local.service_name
    }
  )
}

resource "aws_ecs_task_definition" "fargate_task" {
  family                   = local.service_name
  network_mode             = "awsvpc"
  cpu                      = local.container_definition.0.cpu
  memory                   = local.container_definition.0.memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode(local.container_definition)
  execution_role_arn       = aws_iam_role.fargate_execution.arn
  task_role_arn            = local.iam_fargate_role_arn
  volume {
    name = "efs_volume"
    efs_volume_configuration {
      file_system_id = local.efs_id
      # https://docs.aws.amazon.com/AmazonECS/latest/userguide/efs-volumes.html
      root_directory = "/"
      transit_encryption  = "ENABLED"
      authorization_config {
        access_point_id = local.efs_ap_fargate_id
        iam             = "ENABLED"
      }
    }
  }
  tags = merge(
    local.common_tags,
    {
      Name = local.service_name
    }
  )
}

resource "aws_ecs_service" "haproxy_egress" {
  name            = local.service_name
  cluster         = local.fargate_cluster_name
  task_definition = aws_ecs_task_definition.fargate_task.arn
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.fargate_task.id]
    subnets         = local.private_subnets
  }
}
