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
  map_public_ip_on_launch = count.index==0?true:false
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
    Name = "route_table"
  }
}


resource "aws_route_table_association" "rta" {
  count = length(var.subnet_cidr)-1
  subnet_id      = element(aws_subnet.subnet.*.id,count.index)
  route_table_id = aws_route_table.rt.id
}

resource "aws_instance" "web" {
  count = length(var.subnet_cidr)
  ami           = var.ami
  instance_type = var.type[1]
  subnet_id = element(aws_subnet.subnet.*.id,count.index)
  key_name = "chahkkey"
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "OS${count.index+1}"
  }
}

resource "aws_security_group" "sg" {
  name        = "sgterraform"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "httpallow"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "httpallow"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
    ipv6_cidr_blocks = ["::/0"]
  }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform_sg"
  }
}
