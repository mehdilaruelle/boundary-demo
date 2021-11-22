data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "boundary" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.boundary.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 0)
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.boundary.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.boundary.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id                  = aws_vpc.boundary.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private subnet ${count.index}"
  }
}
