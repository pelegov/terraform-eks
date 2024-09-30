### VPC Vars ###
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "eks-cluster"
  }
}

### EKS Vars ###

variable "cluster_name" {
  default = "ingestify-dev"
  type    = string
}

variable "instance_type" {
  default = "t3.medium"
  type    = string
}

variable "role_name_cluster" {
  description = "role name for cluster"
  default     = "eks-dev-cluster-role"
  type        = string
}

variable "role_name_node_group" {
  description = "role name for node group"
  default     = "eks-dev-node-role"
  type        = string
}