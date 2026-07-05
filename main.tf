terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "terraform-state-lesson-8-9-mykhailov-viacheslav-20260628"
  table_name  = "terraform-locks-lesson-8-9"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]

  availability_zones = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c"
  ]

  vpc_name     = "lesson-8-9-vpc"
  cluster_name = "lesson-8-9-eks"
}

module "ecr" {
  source = "./modules/ecr"

  ecr_name        = "lesson-8-9-ecr"
  scan_on_push    = true
  encryption_type = "AES256"
  kms_key_arn     = null
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "lesson-8-9-eks"
  node_group_name = "lesson-8-9-node-group"

  subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = ["t3.medium"]
  node_desired_size   = 2
  node_min_size       = 2
  node_max_size       = 6
}