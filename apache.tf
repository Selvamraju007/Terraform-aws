
provider "aws" {
  region     = "ap-south-1"
  profile = "sheersh"
}

resource "aws_instance" "web" {
  ami           = "ami-079b5e5b3971bd10d"
  instance_type = "t2.micro"
  security_groups = ["launch-wizard-4"]
  key_name = "terraform"
  tags = {
    Name = "TEST_OS"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Lenovo/Downloads/terraform.pem")
    host     = aws_instance.web.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php -y",
      "sudo systemctl enable httpd --now", 
    ]
  }
}

resource "aws_ebs_volume" "vol1" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1  
  tags = {
    Name = "ebs_vol"
  }
}
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.vol1.id
  instance_id = aws_instance.web.id
}
resource "null_resource" "one" {
  depends_on = [
	aws_volume_attachment.ebs_att
  ]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Lenovo/Downloads/terraform.pem")
    host     = aws_instance.web.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo yum install git -y",
      "sudo git clone https://github.com/sheersh2001/Terraform.git /var/www/html/sheersh",
    ]
  }
}
resource "null_resource" "two" {
    depends_on = [
	null_resource.one
    ]
    provisioner "local-exec" {
       command = "chrome http://${aws_instance.web.public_ip}/sheersh/index.php"
  }
}
