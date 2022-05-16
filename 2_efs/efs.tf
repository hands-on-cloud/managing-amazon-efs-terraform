locals {
  resource_name = "${local.prefix}-efs"
}

# EFS file system

resource "aws_efs_file_system" "shared_efs" {
  creation_token = local.resource_name

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = merge(
    {
      Name = local.resource_name
    },
    local.common_tags
  )
}

# EFS file system policy

resource "aws_efs_file_system_policy" "shared_efs" {
  file_system_id = aws_efs_file_system.shared_efs.id

  bypass_policy_lockout_safety_check = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AccessThroughMountTarget",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientMount"
            ],
            "Resource": "${aws_efs_mount_target.shared_fs[0].file_system_arn}",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                },
                "Bool": {
                    "elasticfilesystem:AccessedViaMountTarget": "true"
                }
            }
        },
        {
            "Sid": "FargateAccess",
            "Effect": "Allow",
            "Principal": { "AWS": "${aws_iam_role.fargate_role.arn}" },
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                },
                "StringEquals": {
                    "elasticfilesystem:AccessPointArn" : "${aws_efs_access_point.fargate.arn}"
                }
            }
        },
        {
            "Sid": "LambdaAccess",
            "Effect": "Allow",
            "Principal": { "AWS": "${aws_iam_role.lambda_role.arn}" },
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                },
                "StringEquals": {
                    "elasticfilesystem:AccessPointArn" : "${aws_efs_access_point.lambda.arn}"
                }
            }
        }
    ]
}
POLICY
}

# EFS mount target

resource "aws_security_group" "shared_efs" {
  name        = "${local.prefix}-sg"
  description = "Allow EFS inbound traffic from VPC"
  vpc_id      = local.vpc_id

  ingress {
    description      = "NFS traffic from VPC"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = [local.vpc_cidr]
  }

  tags = merge(
    {
      Name = local.resource_name
    },
    local.common_tags
  )
}

resource "aws_efs_mount_target" "shared_fs" {
  count = length(local.private_subnets)
  file_system_id = aws_efs_file_system.shared_efs.id
  subnet_id      = local.private_subnets[count.index]
  security_groups = [ aws_security_group.shared_efs.id ]
}

# EFS access points

resource "aws_efs_access_point" "lambda" {
  file_system_id = aws_efs_file_system.shared_efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/lambda"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }

  tags = merge(
    {
      Name = local.resource_name
    },
    local.common_tags
  )
}

resource "aws_efs_access_point" "fargate" {
  file_system_id = aws_efs_file_system.shared_efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/fargate"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }

  tags = merge(
    {
      Name = local.resource_name
    },
    local.common_tags
  )
}
