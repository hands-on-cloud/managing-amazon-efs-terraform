# AWS Fargate Service

This is a demo repository for the [How to manage Amazon EFS using Terraform](https://hands-on.cloud/how-to-manage-amazon-efs-using-terraform/) article.

This module sets up the following AWS services:

* AWS Fargate Service with demo Falsk application

![AWS Fargate cluster](https://hands-on.cloud/wp-content/uploads/2022/05/How-to-manage-Amazon-EFS-using-Terraform-Fargate-cluster-deployment.png)

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
