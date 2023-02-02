resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "${var.project_name}-vpc"
    Owner = var.admin_user
  }
}

data "http" "ip" {
  url = "https://ifconfig.me"
}

resource "aws_security_group" "vpc_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "${data.http.ip.response_body}/32",
      aws_vpc.vpc.cidr_block,
    ]
  }

  ingress {
    from_port = 8443
    to_port   = 8443
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.vpc.cidr_block
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  name = var.project_name
  lifecycle {
    ignore_changes = [
      ingress,
      egress,
    ]
  }
  tags = {
    Name                     = "${var.project_name}-sg"
    "karpenter.sh/discovery" = "true"
    Owner                    = var.admin_user
  }
  depends_on = [
    aws_vpc.vpc,
    aws_route_table.public_route_table,
    aws_route_table.private_route_table,
  ]
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidr_blocks[0]
  availability_zone = "${var.region}a"
  tags = {
    Name                                                = "${var.project_name}-private-subnet-a"
    "kubernetes.io/role/internal-elb"                   = "1"
    "kubernetes.io/role/${var.cluster_iam_role_name}"   = "owned"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
    "karpenter.sh/discovery"                            = "true"
    Owner                                               = var.admin_user
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_blocks[3]
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name                                                = "${var.project_name}-public-subnet-b"
    "kubernetes.io/role/elb"                            = "1"
    "kubernetes.io/role/${var.cluster_iam_role_name}"   = "owned"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
    Owner                                               = var.admin_user
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidr_blocks[1]
  availability_zone = "${var.region}b"
  tags = {
    Name                                                = "${var.project_name}-private-subnet-b"
    "kubernetes.io/role/internal-elb"                   = "1"
    "kubernetes.io/role/${var.cluster_iam_role_name}"   = "owned"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
    "karpenter.sh/discovery"                            = "true"
    Owner                                               = var.admin_user
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_blocks[2]
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name                                                = "${var.project_name}-public-subnet-a"
    "kubernetes.io/role/elb"                            = "1"
    "kubernetes.io/role/${var.cluster_iam_role_name}"   = "owned"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
    Owner                                               = var.admin_user
  }
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "${var.project_name}-internet-gateway"
    Owner = var.admin_user
  }
  depends_on = [
    aws_subnet.public_subnet_1,
    aws_subnet.public_subnet_2,
    aws_subnet.private_subnet_1,
    aws_subnet.private_subnet_2,
  ]
}

resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name  = "${var.project_name}-eip"
    Owner = var.admin_user
  }
  depends_on = [
    aws_internet_gateway.internet_gateway
  ]
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name  = "${var.project_name}-nat-gateway"
    Owner = var.admin_user
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "${var.project_name}-private-route-table"
    Owner = var.admin_user
  }
  depends_on = [
    aws_internet_gateway.internet_gateway
  ]
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = var.private_destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "${var.project_name}-public-route-table"
    Owner = var.admin_user
  }
  depends_on = [
    aws_internet_gateway.internet_gateway
  ]
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = var.public_destination_cidr_block
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "private_rta_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
