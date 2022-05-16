## VPC Endpoints Security Group
#
#resource "aws_security_group" "vpc_endpoint" {
#  name   = "${local.prefix}-fargate-vpce-sg"
#  vpc_id = local.vpc_id
#  ingress {
#    from_port   = 443
#    to_port     = 443
#    protocol    = "tcp"
#    cidr_blocks = [local.vpc_cidr]
#  }
#  tags = local.common_tags
#}
#
## Fargate VPC Endpoints
#
#
## S3 VPC Endpoint been set up at EC2 section (SSM SG)
#
##data "aws_vpc_endpoint_service" "s3" {
##  service      = "s3"
##  service_type = "Gateway"
##}
##
##resource "aws_vpc_endpoint" "s3" {
##  vpc_id            = local.vpc_id
##  service_name      = data.aws_vpc_endpoint_service.s3.service_name
##  vpc_endpoint_type = "Gateway"
##}
##
##data "aws_subnet" "private" {
##  for_each = toset(local.private_subnets)
##  id       = each.value
##}
##
##data "aws_route_table" "private" {
##  for_each = data.aws_subnet.private
##  subnet_id = each.value.id
##}
##
##resource "aws_vpc_endpoint_route_table_association" "s3" {
##  for_each = data.aws_route_table.private
##  route_table_id  = each.value.id
##  vpc_endpoint_id = aws_vpc_endpoint.s3.id
##}
#
##resource "aws_vpc_endpoint" "s3" {
##  vpc_id            = local.vpc_id
##  service_name      = data.aws_vpc_endpoint_service.s3.service_name
##  vpc_endpoint_type = "Gateway"
##  route_table_ids   = data.terraform_remote_state.vpc.outputs.private_route_table_ids
##
##  tags = {
##    Name        = "s3-endpoint"
##    Environment = "dev"
##  }
##}
#
#data "aws_vpc_endpoint_service" "dkr" {
#  service      = "dkr"
#  service_type = "Interface"
#}
#
#resource "aws_vpc_endpoint" "dkr" {
#  vpc_id              = local.vpc_id
#  private_dns_enabled = true
#  service_name        = data.aws_vpc_endpoint_service.dkr.service_name
#  vpc_endpoint_type   = "Interface"
#  security_group_ids = [
#    aws_security_group.vpc_endpoint.id,
#  ]
#  subnet_ids = local.private_subnets
#
#  tags = merge(
#    {
#      Name = "${local.prefix}-dkr-endpoint"
#    },
#    local.common_tags
#  )
#}
#
#data "aws_vpc_endpoint_service" "ecr_api" {
#  service      = "ecr.api"
#  service_type = "Interface"
#}
#
#resource "aws_vpc_endpoint" "ecr_api" {
#  vpc_id              = local.vpc_id
#  private_dns_enabled = true
#  service_name        = data.aws_vpc_endpoint_service.ecr_api.service_name
#  vpc_endpoint_type   = "Interface"
#  security_group_ids = [
#    aws_security_group.vpc_endpoint.id,
#  ]
#  subnet_ids = local.private_subnets
#
#  tags = merge(
#    {
#      Name = "${local.prefix}-ecr-api-endpoint"
#    },
#    local.common_tags
#  )
#}
#
## CloudWatch Logs VPC Endpoint been set up at EC2 section (SSM SG)
#
##data "aws_vpc_endpoint_service" "logs" {
##  service      = "logs"
##  service_type = "Interface"
##}
##
##resource "aws_vpc_endpoint" "logs" {
##  vpc_id              = local.vpc_id
##
##  private_dns_enabled = true
##  service_name        = data.aws_vpc_endpoint_service.logs.service_name
##  vpc_endpoint_type   = "Interface"
##  security_group_ids = [
##    aws_security_group.vpc_endpoint.id,
##  ]
##  subnet_ids = local.private_subnets
##
##  tags = merge(
##    {
##      Name = "${local.prefix}-logs-endpoint"
##    },
##    local.common_tags
##  )
##}
#
#data "aws_vpc_endpoint_service" "secretsmanager" {
#  service      = "secretsmanager"
#  service_type = "Interface"
#}
#
#resource "aws_vpc_endpoint" "secretsmanager" {
#  vpc_id              = local.vpc_id
#
#  private_dns_enabled = true
#  service_name        = data.aws_vpc_endpoint_service.secretsmanager.service_name
#  vpc_endpoint_type   = "Interface"
#  security_group_ids = [
#    aws_security_group.vpc_endpoint.id,
#  ]
#  subnet_ids = local.private_subnets
#
#  tags = merge(
#    {
#      Name = "${local.prefix}-secretsmanager-endpoint"
#    },
#    local.common_tags
#  )
#}
#
##data "aws_vpc_endpoint_service" "ssm" {
##  service      = "ssm"
##  service_type = "Interface"
##}
##
##resource "aws_vpc_endpoint" "ssm" {
##  vpc_id              = local.vpc_id
##
##  private_dns_enabled = true
##  service_name        = data.aws_vpc_endpoint_service.ssm.service_name
##  vpc_endpoint_type   = "Interface"
##  security_group_ids = [
##    aws_security_group.vpc_endpoint.id,
##  ]
##  subnet_ids = local.private_subnets
##
##  tags = merge(
##    {
##      Name = "${local.prefix}-ssm-endpoint"
##    },
##    local.common_tags
##  )
##}
#
#data "aws_vpc_endpoint_service" "kms" {
#  service      = "kms"
#  service_type = "Interface"
#}
#
#resource "aws_vpc_endpoint" "kms" {
#  vpc_id              = local.vpc_id
#
#  private_dns_enabled = true
#  service_name        = "com.amazonaws.${local.aws_region}.kms"
#  vpc_endpoint_type   = "Interface"
#  security_group_ids = [
#    aws_security_group.vpc_endpoint.id,
#  ]
#  subnet_ids = local.private_subnets
#
#  tags = merge(
#    {
#      Name = "${local.prefix}-kms-endpoint"
#    },
#    local.common_tags
#  )
#}
