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

  container_name    = "flask-demo-app"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = local.remote_state_bucket
    region = local.remote_state_bucket_region
    key    = local.vpc_state_file
  }
}

locals {
  aws_account_id = data.aws_caller_identity.local.account_id
}

data "aws_caller_identity" "local" {}

data "archive_file" "flask_demo_app" {
  type        = "zip"
  source_dir = "${path.module}/${local.container_name}"
  output_path = "${path.module}/${local.container_name}.zip"
}

resource "aws_ecr_repository" "flask_demo_app" {
  name                 = "${local.prefix}-${local.container_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    {
      Name = "${local.prefix}-${local.container_name}"
    },
    local.common_tags
  )
}

resource "null_resource" "build_image" {
  triggers = {
    policy_sha1 = data.archive_file.flask_demo_app.output_sha
  }

  provisioner "local-exec" {
    command = <<EOF
      cd ${local.container_name}
      docker build -t ${local.prefix}-${local.container_name} -f Dockerfile .
    EOF
  }
}

resource "null_resource" "push_image" {
  depends_on = [null_resource.build_image]

  triggers = {
    policy_sha1 = data.archive_file.flask_demo_app.output_sha
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password --region ${local.aws_region} | docker login --username AWS --password-stdin ${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com && \
      docker tag ${local.prefix}-${local.container_name}:latest ${aws_ecr_repository.flask_demo_app.repository_url}:latest && \
      docker push ${aws_ecr_repository.flask_demo_app.repository_url}:latest
    EOF
  }
}
