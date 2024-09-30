

### VPC Creation
resource "aws_vpc" "ingestify-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ingestify-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ingestify-vpc.id

  tags = {
    Name = "ingestify-igw"
  }
}

### Create 2 AZ
data "aws_availability_zones" "available" {
  state = "available"
}

### Create Publice Subnets
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.ingestify-vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "ingestify-public-subnet-${count.index + 1}"
    Tier = "Public"
  }
}

#Create Private Subnets
resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.ingestify-vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "ingestify-private-subnet-${count.index + 1}"
    Tier = "Private"
  }
}

# Create route table for IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ingestify-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "eks-public-rt"
  }
}

# Link route tabels for pubic subnet
resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Create EIP for private subnet
resource "aws_eip" "nat_eip" {
  count = var.az_count
  vpc   = true

  tags = {
    Name = "eks-nat-eip-${count.index + 1}"
  }
}

# Create NAT GW
resource "aws_nat_gateway" "nat_gw" {
  count         = var.az_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "eks-nat-gw-${count.index + 1}"
  }
}


# Create Route table for Private subnets
resource "aws_route_table" "private_rt" {
  count  = var.az_count
  vpc_id = aws_vpc.ingestify-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "eks-private-rt-${count.index + 1}"
  }
}


#Link Route Table to Private subnets
resource "aws_route_table_association" "private_rt_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

# Create Security Group for VPC
resource "aws_security_group" "vpc_sg" {
  name        = "eks-vpc-sg"
  description = "Security group for EKS VPC"
  vpc_id      = aws_vpc.ingestify-vpc.id

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

  tags = {
    Name = "eks-vpc-sg"
  }
}
