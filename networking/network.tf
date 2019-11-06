resource "aws_vpc" "demovpc" {
  cidr_block = "10.0.0.0/16"
}
#### subnets
resource "aws_subnet" "priv1" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "priv2" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1b"
}

resource "aws_subnet" "pub1" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
}
resource "aws_subnet" "pub2" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
}

## public routes 
resource "aws_internet_gateway" "demoigw" {
  vpc_id = "${aws_vpc.demovpc.id}"
}
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.demovpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demoigw.id}"
  }
}
resource "aws_route_table_association" "public1" {
  subnet_id      = "${aws_subnet.pub1.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "public2" {
  subnet_id      = "${aws_subnet.pub2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

### nat routes
resource "aws_eip" "natgweip" {
  vpc = true
}
resource "aws_nat_gateway" "priv1" {
  allocation_id = "${aws_eip.natgweip.id}"
  subnet_id     = "${aws_subnet.pub1.id}"
  depends_on    = ["aws_internet_gateway.demoigw"]
}
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.demovpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.priv1.id}"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = "${aws_subnet.priv1.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private2" {
  subnet_id      = "${aws_subnet.priv2.id}"
  route_table_id = "${aws_route_table.private.id}"
}

output "vpc" {
  value = "${aws_vpc.demovpc.id}"
}
output "cidr" {
  value = "${aws_vpc.demovpc.cidr_block}"
}
output "priv1subnet" {
  value = "${aws_subnet.priv1.id}"
}
output "priv2subnet" {
  value = "${aws_subnet.priv2.id}"
}
output "pub1subnet" {
  value = "${aws_subnet.pub1.id}"
}
output "pub2subnet" {
  value = "${aws_subnet.pub2.id}"
}