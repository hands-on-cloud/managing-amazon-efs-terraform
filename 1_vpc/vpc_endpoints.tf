# VPC Endpoints Security Group

resource "aws_security_group" "vpc_endpoint" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  name      = "${local.prefix}-vpce-sg"
  vpc_id    = module.vpc.vpc_id
  tags      = merge(
    {
      Name = "${local.prefix}-vpce-sg"
    },
    local.common_tags
  )
}

# SSM VPC Endpoints

data "aws_vpc_endpoint_service" "ssm" {
  service      = "ssm"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.vpc.vpc_id

  private_dns_enabled = true
  service_name        = data.aws_vpc_endpoint_service.ssm.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  #subnet_ids = module.vpc.private_subnets

  tags = merge(
    {
      Name = "${local.prefix}-ssm-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "ssm" {
  count = length(module.vpc.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.ssm.id
  subnet_id       = module.vpc.private_subnets[count.index]
}

data "aws_vpc_endpoint_service" "ec2messages" {
  service      = "ec2messages"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ec2messages.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  private_dns_enabled = true

  tags = merge(
    {
      Name = "${local.prefix}-ec2messages-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "ec2messages" {
  count = length(module.vpc.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.ec2messages.id
  subnet_id       = module.vpc.private_subnets[count.index]
}

data "aws_vpc_endpoint_service" "ssmmessages" {
  service      = "ssmmessages"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ssmmessages.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  private_dns_enabled = true

  tags = merge(
    {
      Name = "${local.prefix}-ssmmessages-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "ssmmessages" {
  count = length(module.vpc.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.ssmmessages.id
  subnet_id       = module.vpc.private_subnets[count.index]
}

# S3 VPC Gateway Endpoint

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"

  tags = merge(
    {
      Name = "${local.prefix}-s3-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  count = length(module.vpc.private_route_table_ids)
  route_table_id  = module.vpc.private_route_table_ids[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

# KMS VPC Endpoint

data "aws_vpc_endpoint_service" "kms" {
  service      = "kms"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.kms.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  private_dns_enabled = true

  tags = merge(
    {
      Name = "${local.prefix}-kms-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "kms" {
  count = length(module.vpc.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.kms.id
  subnet_id       = module.vpc.private_subnets[count.index]
}

# CloudWatch Logs VPC Endpoint

data "aws_vpc_endpoint_service" "logs" {
  service      = "logs"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.vpc.vpc_id

  private_dns_enabled = true
  service_name        = data.aws_vpc_endpoint_service.logs.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  tags = merge(
    {
      Name = "${local.prefix}-logs-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "logs" {
  count = length(module.vpc.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.logs.id
  subnet_id       = module.vpc.private_subnets[count.index]
}

# ECR VPC Endpoints

data "aws_vpc_endpoint_service" "ecr_dkr" {
  service      = "ecr.dkr"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = data.aws_vpc_endpoint_service.ecr_dkr.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  #subnet_ids = local.private_subnets

  tags = merge(
    {
      Name = "${local.prefix}-ecr-dkr-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "ecr_dkr" {
  count = length(module.vpc.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.ecr_dkr.id
  subnet_id       = module.vpc.private_subnets[count.index]
}

data "aws_vpc_endpoint_service" "ecr_api" {
  service      = "ecr.api"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = data.aws_vpc_endpoint_service.ecr_api.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  #subnet_ids = local.private_subnets

  tags = merge(
    {
      Name = "${local.prefix}-ecr-api-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "ecr_api" {
  count = length(module.vpc.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.ecr_api.id
  subnet_id       = module.vpc.private_subnets[count.index]
}

# SecretsManager VPC Endpoint

data "aws_vpc_endpoint_service" "secretsmanager" {
  service      = "secretsmanager"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = module.vpc.vpc_id

  private_dns_enabled = true
  service_name        = data.aws_vpc_endpoint_service.secretsmanager.service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  #subnet_ids = local.private_subnets

  tags = merge(
    {
      Name = "${local.prefix}-secretsmanager-endpoint"
    },
    local.common_tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "secretsmanager" {
  count = length(module.vpc.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager.id
  subnet_id       = module.vpc.private_subnets[count.index]
}
