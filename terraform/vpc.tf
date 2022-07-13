resource "aws_vpc" "pachaform_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

data "http" "ip" {
  url = "https://ifconfig.me"
}

resource "aws_security_group" "pachaform_sg" {
  vpc_id = aws_vpc.pachaform_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "${data.http.ip.body}/32",
      aws_vpc.pachaform_vpc.cidr_block,
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
  depends_on = [
    aws_vpc.pachaform_vpc
  ]
}

resource "aws_subnet" "pachaform_private_subnet_1" {
  vpc_id            = aws_vpc.pachaform_vpc.id
  cidr_block        = var.subnet_cidr_blocks[0]
  availability_zone = "${var.region}a"
  tags = {
    Name                                                         = "${var.project_name}-private-subnet-a"
    "kubernetes.io/role/internal-elb"                            = "1"
    "kubernetes.io/role/${aws_iam_role.pachaform-cluster.name}" = "owned"
    "kubernetes.io/cluster/${var.project_name}-cluster"         = "shared"
  }
}

resource "aws_subnet" "pachaform_public_subnet_2" {
  vpc_id                  = aws_vpc.pachaform_vpc.id
  cidr_block              = var.subnet_cidr_blocks[3]
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name                                                         = "${var.project_name}-public-subnet-b"
    "kubernetes.io/role/elb"                                     = "1"
    "kubernetes.io/role/${aws_iam_role.pachaform-cluster.name}" = "owned"
    "kubernetes.io/cluster/${var.project_name}-cluster"         = "shared"
  }
}

resource "aws_subnet" "pachaform_private_subnet_2" {
  vpc_id            = aws_vpc.pachaform_vpc.id
  cidr_block        = var.subnet_cidr_blocks[1]
  availability_zone = "${var.region}b"
  tags = {
    Name                                                         = "${var.project_name}-private-subnet-b"
    "kubernetes.io/role/internal-elb"                            = "1"
    "kubernetes.io/role/${aws_iam_role.pachaform-cluster.name}" = "owned"
    "kubernetes.io/cluster/${var.project_name}-cluster"         = "shared"
  }
}

resource "aws_subnet" "pachaform_public_subnet_1" {
  vpc_id                  = aws_vpc.pachaform_vpc.id
  cidr_block              = var.subnet_cidr_blocks[2]
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name                                                         = "${var.project_name}-public-subnet-a"
    "kubernetes.io/role/elb"                                     = "1"
    "kubernetes.io/role/${aws_iam_role.pachaform-cluster.name}" = "owned"
    "kubernetes.io/cluster/${var.project_name}-cluster"         = "shared"
  }
}


resource "aws_internet_gateway" "pachaform_internet_gateway" {
  vpc_id = aws_vpc.pachaform_vpc.id

  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
  depends_on = [
    aws_vpc.pachaform_vpc
  ]
}

resource "aws_eip" "pachaform_eip" {
  vpc = true
  tags = {
    Name = "${var.project_name}-eip"
  }
  depends_on = [
    aws_internet_gateway.pachaform_internet_gateway
  ]
}

resource "aws_nat_gateway" "pachaform_nat_gateway" {
  allocation_id = aws_eip.pachaform_eip.id
  subnet_id     = aws_subnet.pachaform_public_subnet_1.id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
  depends_on = [
    aws_eip.pachaform_eip
  ]
}

resource "aws_route_table" "pachaform_private_route_table" {
  vpc_id = aws_vpc.pachaform_vpc.id

  tags = {
    Name = "${var.project_name}-private-route-table"
  }
  depends_on = [
    aws_vpc.pachaform_vpc,
    aws_internet_gateway.pachaform_internet_gateway
  ]
}

resource "aws_route" "pachaform_private_route" {
  route_table_id         = aws_route_table.pachaform_private_route_table.id
  destination_cidr_block = var.private_destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.pachaform_nat_gateway.id
  depends_on = [
    aws_route_table.pachaform_private_route_table
  ]
}

resource "aws_route_table" "pachaform_public_route_table" {
  vpc_id = aws_vpc.pachaform_vpc.id

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
  depends_on = [
    aws_vpc.pachaform_vpc,
    aws_internet_gateway.pachaform_internet_gateway
  ]
}

resource "aws_route" "pachaform_public_route" {
  route_table_id         = aws_route_table.pachaform_public_route_table.id
  destination_cidr_block = var.public_destination_cidr_block
  gateway_id             = aws_internet_gateway.pachaform_internet_gateway.id
  depends_on = [
    aws_route_table.pachaform_public_route_table
  ]
}

resource "aws_route_table_association" "pachaform_private_rta_1" {
  subnet_id      = aws_subnet.pachaform_private_subnet_1.id
  route_table_id = aws_route_table.pachaform_private_route_table.id
  depends_on = [
    aws_subnet.pachaform_private_subnet_1,
    aws_route_table.pachaform_private_route_table
  ]
}

resource "aws_route_table_association" "pachaform_private_rta_2" {
  subnet_id      = aws_subnet.pachaform_private_subnet_2.id
  route_table_id = aws_route_table.pachaform_private_route_table.id
  depends_on = [
    aws_subnet.pachaform_private_subnet_2,
    aws_route_table.pachaform_private_route_table
  ]
}

resource "aws_route_table_association" "pachaform_public_rta_1" {
  subnet_id      = aws_subnet.pachaform_public_subnet_1.id
  route_table_id = aws_route_table.pachaform_public_route_table.id
  depends_on = [
    aws_subnet.pachaform_public_subnet_1,
    aws_route_table.pachaform_public_route_table
  ]
}

resource "aws_route_table_association" "pachaform_public_rta_2" {
  subnet_id      = aws_subnet.pachaform_public_subnet_2.id
  route_table_id = aws_route_table.pachaform_public_route_table.id
  depends_on = [
    aws_subnet.pachaform_public_subnet_2,
    aws_route_table.pachaform_public_route_table
  ]
}