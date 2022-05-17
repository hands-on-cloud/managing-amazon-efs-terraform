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
