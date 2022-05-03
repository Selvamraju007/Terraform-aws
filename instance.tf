provider "aws" {
  region     = "ap-south-1"
  profile    = "sheersh"
}
resource "aws_instance" "OS1" {
  ami           = "ami-0a3277ffce9146b74" 
  instance_type = "t2.small" 
  tags = {
    Name = "SHEERSH_OS"
  }
}
resource "aws_ebs_volume" "vol1" {
  availability_zone = aws_instance.OS1.availability_zone
  size              = 2  

  tags = {
    Name = "ebs_vol"
  }
}
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.vol1.id
  instance_id = aws_instance.OS1.id
}
