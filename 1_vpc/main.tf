locals {
  prefix        = "amazon-efs-terraform"
  vpc_name      = "${local.prefix}-vpc"
  vpc_cidr      = var.vpc_cidr
  common_tags   = {
    Environment = "dev"
    Project     = "hands-on.cloud"
  }
}
