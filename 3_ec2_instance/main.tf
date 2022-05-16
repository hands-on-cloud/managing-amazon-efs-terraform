locals {
  remote_state_bucket_region    = "us-west-2"
  remote_state_bucket           = "hands-on-cloud-terraform-remote-state-s3"
  vpc_state_file                = "amazon-efs-terraform-vpc.tfstate"
  efs_state_file                = "amazon-efs-terraform.tfstate"

  aws_region        = var.aws_region
  prefix            = data.terraform_remote_state.vpc.outputs.prefix
  common_tags       = data.terraform_remote_state.vpc.outputs.common_tags
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr          = data.terraform_remote_state.vpc.outputs.vpc_cidr
  public_subnets    = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets   = data.terraform_remote_state.vpc.outputs.private_subnets

  ec2_instance_type = "t3.micro"

  iam_ec2_role_name = data.terraform_remote_state.efs.outputs.iam_ec2_role_name
  efs_id            = data.terraform_remote_state.efs.outputs.efs_id
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
