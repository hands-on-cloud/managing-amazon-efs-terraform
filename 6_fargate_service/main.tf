locals {
  remote_state_bucket_region              = "us-west-2"
  remote_state_bucket                     = "hands-on-cloud-terraform-remote-state-s3"
  vpc_state_file                          = "amazon-efs-terraform-vpc.tfstate"
  efs_state_file                          = "amazon-efs-terraform.tfstate"
  fargate_cluster_state_file              = "amazon-efs-terraform-fargate-cluster.tfstate"
  fargate_container_state_file            = "amazon-efs-terraform-fargate-container.tfstate"

  aws_region                              = var.aws_region
  prefix                                  = data.terraform_remote_state.vpc.outputs.prefix
  common_tags                             = data.terraform_remote_state.vpc.outputs.common_tags
  vpc_id                                  = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr                                = data.terraform_remote_state.vpc.outputs.vpc_cidr
  public_subnets                          = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets                         = data.terraform_remote_state.vpc.outputs.private_subnets

  container_name                          = "flask-demo-app"
  container_file_system_local_mount_path  = "/mnt/efs"
  container_repository_url                = data.terraform_remote_state.fargate_container.outputs.repository_url
  fargate_cluster_name                    = data.terraform_remote_state.fargate_cluster.outputs.aws_ecs_cluster_name

  iam_fargate_role_name                   = data.terraform_remote_state.efs.outputs.iam_fargate_role_name
  iam_fargate_role_arn                    = data.terraform_remote_state.efs.outputs.iam_fargate_role_arn
  efs_id                                  = data.terraform_remote_state.efs.outputs.efs_id
  efs_ap_fargate_id                       = data.terraform_remote_state.efs.outputs.efs_ap_fargate_id
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    region = local.remote_state_bucket_region
    key    = local.vpc_state_file
  }
}

data "terraform_remote_state" "efs" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    region = local.remote_state_bucket_region
    key    = local.efs_state_file
  }
}

data "terraform_remote_state" "fargate_cluster" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    region = local.remote_state_bucket_region
    key = local.fargate_cluster_state_file
  }
}

data "terraform_remote_state" "fargate_container" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    region = local.remote_state_bucket_region
    key = local.fargate_container_state_file
  }
}
