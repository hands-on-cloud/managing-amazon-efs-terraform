# Latest Amazon Linux 2 AMI

locals {
  ec2_file_system_local_mount_path = "/mnt/efs"
}

data "aws_ami" "amazon_linux_2_latest" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

# EC2 demo instance

resource "aws_iam_policy_attachment" "ec2_role" {
  name       = "${local.prefix}-ec2-role"
  roles      = [ local.iam_ec2_role_name ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "amazon_linux_2" {
  name = "${local.prefix}-amazon-linux-2"
  role = local.iam_ec2_role_name
}

resource "aws_security_group" "amazon_linux_2" {
  name        = "${local.prefix}-amazon-linux-2"
  description = "Amazon Linux 2 SG"
  vpc_id      = local.vpc_id

  egress = [
    {
      description      = "ALL Traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = merge(
    {
      Name = "${local.prefix}-amazon-linux-2"
    },
    local.common_tags
  )
}

resource "aws_network_interface" "amazon_linux_2" {
  subnet_id       = local.private_subnets[1]
  security_groups = [aws_security_group.amazon_linux_2.id]
}

resource "aws_instance" "amazon_linux_2" {
  ami                  = data.aws_ami.amazon_linux_2_latest.id
  instance_type        = local.ec2_instance_type
  availability_zone    = "${local.aws_region}b"
  iam_instance_profile = aws_iam_instance_profile.amazon_linux_2.name

  network_interface {
    network_interface_id = aws_network_interface.amazon_linux_2.id
    device_index         = 0
  }

  user_data = <<EOF
#!/bin/bash
#yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
#systemctl start amazon-ssm-agent
mkdir -p ${local.ec2_file_system_local_mount_path}
yum install -y amazon-efs-utils
mount -t efs -o iam,tls ${local.efs_id} ${local.ec2_file_system_local_mount_path}
echo "${local.efs_id} ${local.ec2_file_system_local_mount_path} efs _netdev,tls,iam 0 0" >> /etc/fstab
# Creating demo content for other services
mkdir -p ${local.ec2_file_system_local_mount_path}/fargate
mkdir -p ${local.ec2_file_system_local_mount_path}/lambda
df -h > ${local.ec2_file_system_local_mount_path}/fargate/demo.txt
df -h > ${local.ec2_file_system_local_mount_path}/lambda/demo.txt
chown ec2-user:ec2-user -R ${local.ec2_file_system_local_mount_path}
  EOF
  user_data_replace_on_change = true

  tags = merge(
    {
      Name = "${local.prefix}-amazon-linux-2"
    },
    local.common_tags
  )
}
