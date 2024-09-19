region               = "us-east-1"
vpc_cidr             = "10.1.0.0/16"
az_count             = 2
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
tags = {
  Environment = "dev"
  Project     = "eks-cluster"
}
