
resource "aws_vpc" "private-sub-testing" {
cidr_block = "10.0.0.0/16"
enable_dns_hostnames = true
}
resource "aws_subnet" "PUBLIC" {
vpc_id = aws_vpc.private-sub-testing.id
cidr_block = "10.0.2.0/24"
availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "PRIVATE" {
vpc_id = aws_vpc.private-sub-testing.id
cidr_block = "10.0.3.0/24"
availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.private-sub-testing.id
}
resource "aws_route_table" "public" {
vpc_id = aws_vpc.private-sub-testing.id
route {
gateway_id = aws_internet_gateway.igw.id
cidr_block = "0.0.0.0/0"
}
}
resource "aws_route_table" "private" {
vpc_id = aws_vpc.private-sub-testing.id
route {
gateway_id = aws_internet_gateway.igw.id
cidr_block = "0.0.0.0/0"
}
}
resource "aws_route_table_association" "test" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.PUBLIC.id
}
resource "aws_route_table_association" "test1" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.PRIVATE.id
}
resource "aws_security_group" "my-sec-gp" {
name   = "new-sec-gp"
vpc_id = aws_vpc.private-sub-testing.id
ingress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

}
#resource "aws_instance" "public" {
#ami                         = "ami-0b0dcb5067f052a63"
#subnet_id                   = aws_subnet.PUBLIC.id
#availability_zone           = "us-east-1a"
#vpc_security_group_ids = [aws_security_group.my-sec-gp.id]
#key_name                    = "neelakey"
#associate_public_ip_address = true
#instance_type               = "t2.micro"
#user_data =  <<EOF
##!/bin/bash
#yum update -y
#yum install httpd -y
#service httpd start
#chkconfig httpd on
#cd /var/www/html
#echo 'Hello mathi, Welcome To My ec2-insatnce-1' > index.html
#aws s3 mb s3://johnny-aws-guru-s3-bootstrap-01
#aws s3 cp index.html s3://johnny-aws-guru-s3-bootstrap-01
#EOF
#}
#resource "aws_instance" "private" {
#ami                         = "ami-0b0dcb5067f052a63"
#subnet_id                   = aws_subnet.PUBLIC.id
#availability_zone           = "us-east-1a"
#  vpc_security_group_ids      = [aws_security_group.my-sec-gp.id]
#key_name                    = "neelakey"
#instance_type               = "t2.micro"
#associate_public_ip_address = true
#user_data =  <<EOF
##!/bin/bash
#yum update -y
#yum install httpd -y
#service httpd start
#chkconfig httpd on
#cd /var/www/html
#echo 'Hello mathi, Welcome To My ec2-insatnce-2' > index.html
#aws s3 mb s3://johnny-aws-guru-s3-bootstrap-01
#aws s3 cp index.html s3://johnny-aws-guru-s3-bootstrap-01
#EOF
#}

#############################
#Rout53
##########################

#data "aws_ami" "testdata" {
  #owners = ["amazon"]
  #most_recent = true
  #filter {
   # name   = "name"
    #values = ["amzn2-ami-hvm*"]
  #}
#}
#EKS CREATION-CLUSTER
resource "aws_eks_cluster" "eks-m" {
  name     = "ttv1"
  role_arn = "arn:aws:iam::648207145026:role/eks-test-mathi"
  vpc_config {
    subnet_ids = [aws_subnet.PRIVATE.id , aws_subnet.PUBLIC.id]
  }
}
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.eks-m.name
  node_group_name = "nodegp01"
  node_role_arn   = "arn:aws:iam::648207145026:role/worker-node-policy"
  subnet_ids      = [aws_subnet.PRIVATE.id, aws_subnet.PUBLIC.id]
  instance_types = ["t2.micro"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
}

provider "aws" {
  region = "us-east-2"  # Replace with your desired AWS region
}

data "aws_secretsmanager_secret" "my_secret" {
  name = "newsec"  # Specify the name of your secret in AWS Secrets Manager
}

data "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id = data.aws_secretsmanager_secret.my_secret.id
}


#terraform {
#  backend "s3" {
#    bucket         = "ookey1"
#    key            = "mathi/terraform.tfstate"
#    region         = "us-east-2"
#    access_key     = "AKIAWNHN56SPM6TBQIPM"
#    secret_key     = "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"
#    dynamodb_table = "ookey"
#  }
#}
