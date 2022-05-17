<!-- BEGIN_TF_DOCS -->

# Amazon EFS module

This is a demo repository for the [How to manage Amazon EFS using Terraform](https://hands-on.cloud/how-to-manage-amazon-efs-using-terraform/) article.

This module sets up the following AWS services:

* EFS file system
* EFS mount target
* EFS access points
* Blank IAM roles for client resources (EC2 instance, Lambda function and AWS Fargate task)

![Amazon EFS](https://hands-on.cloud/wp-content/uploads/2022/05/How-to-manage-Amazon-EFS-using-Terraform-EFS-deployment-architecture.png)

## Deployment

```sh
terraform init
terraform plan
terraform apply -auto-approve
```

## Tier down

```sh
terraform destroy -auto-approve
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to deploy VPC | `string` | `"us-east-1"` | no |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efs_ap_fargate_arn"></a> [efs\_ap\_fargate\_arn](#output\_efs\_ap\_fargate\_arn) | EFS access point ARN for Fargete tasks |
| <a name="output_efs_ap_fargate_id"></a> [efs\_ap\_fargate\_id](#output\_efs\_ap\_fargate\_id) | EFS access point ID for Fargete tasks |
| <a name="output_efs_ap_lambda_arn"></a> [efs\_ap\_lambda\_arn](#output\_efs\_ap\_lambda\_arn) | EFS access point ARN for Lambda functions |
| <a name="output_efs_ap_lambda_id"></a> [efs\_ap\_lambda\_id](#output\_efs\_ap\_lambda\_id) | EFS access point ID for Lambda functions |
| <a name="output_efs_arn"></a> [efs\_arn](#output\_efs\_arn) | EFS file system ARN |
| <a name="output_efs_dns_name"></a> [efs\_dns\_name](#output\_efs\_dns\_name) | EFS file system DNS name |
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | EFS file system ID |
| <a name="output_iam_ec2_role_arn"></a> [iam\_ec2\_role\_arn](#output\_iam\_ec2\_role\_arn) | IAM role ARN for EC2 instances |
| <a name="output_iam_ec2_role_name"></a> [iam\_ec2\_role\_name](#output\_iam\_ec2\_role\_name) | IAM role name for EC2 instances |
| <a name="output_iam_fargate_role_arn"></a> [iam\_fargate\_role\_arn](#output\_iam\_fargate\_role\_arn) | IAM role ARN for Fargate tasks |
| <a name="output_iam_fargate_role_name"></a> [iam\_fargate\_role\_name](#output\_iam\_fargate\_role\_name) | IAM role name for Fargate tasks |
| <a name="output_iam_lambda_role_arn"></a> [iam\_lambda\_role\_arn](#output\_iam\_lambda\_role\_arn) | IAM role ARN for Lambda functions |
| <a name="output_iam_lambda_role_name"></a> [iam\_lambda\_role\_name](#output\_iam\_lambda\_role\_name) | IAM role name for Lambda functions |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.14.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.9 |
## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_access_point.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.shared_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.shared_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.shared_fs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_role.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.fargate_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_security_group.shared_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_policy_document.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.fargate_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

<!-- END_TF_DOCS -->