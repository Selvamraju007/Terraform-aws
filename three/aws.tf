resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  tags = {
    Name = "sheersh_vpc"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}
resource "aws_subnet" "subnet" {
  count=length(var.subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.subnet_cidr,count.index)
  availability_zone = element(var.az,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-${count.index+1}"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "route_table_sheersh"
  }
}


resource "aws_route_table_association" "rta" {
  count = length(var.subnet_cidr)
  subnet_id      = element(aws_subnet.subnet.*.id,count.index)
  route_table_id = aws_route_table.rt.id
}

resource "aws_instance" "web" {
  count = length(var.subnet_cidr)
  ami           = var.ami
  instance_type = var.type[1]
  subnet_id = element(aws_subnet.subnet.*.id,count.index)
  key_name = "chahkkey"
  vpc_security_group_ids = ["sg-0e9ca3b524759a94c"]
  tags = {
    Name = "OS${count.index+1}"
  }
}
