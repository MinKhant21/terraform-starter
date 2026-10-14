
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "us-east-1a"
  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "us-east-1a"
  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = data.aws_route_table.route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}



resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}


resource "aws_route" "public_internet" {
  route_table_id         = data.aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private-route"
  }

}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_subnet.id
}
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat"
  }
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "nat"
  }
  depends_on = [aws_internet_gateway.gw]

}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}