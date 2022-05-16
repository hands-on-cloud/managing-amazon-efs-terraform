locals {
  remote_state_bucket_region    = "us-west-2"
  remote_state_bucket           = "hands-on-cloud-terraform-remote-state-s3"
  vpc_state_file                = "amazon-efs-terraform-vpc.tfstate"

  aws_region        = var.aws_region
  prefix            = data.terraform_remote_state.vpc.outputs.prefix
  common_tags       = data.terraform_remote_state.vpc.outputs.common_tags
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr          = data.terraform_remote_state.vpc.outputs.vpc_cidr
  public_subnets    = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets   = data.terraform_remote_state.vpc.outputs.private_subnets
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    region = local.remote_state_bucket_region
    key    = local.vpc_state_file
  }
}

# Fargate cluster

resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-fargate-cluster"
  tags = local.common_tags
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}
