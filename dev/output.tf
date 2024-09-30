# Create output
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.ingestify-vpc.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateways" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.nat_gw[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "security_group_id" {
  description = "ID of the security group for VPC"
  value       = aws_security_group.vpc_sg.id
}