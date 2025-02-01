data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm*-24.04-amd64-server-*"]
  }
  
  owners = ["099720109477"]
}

resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  depends_on             = [aws_network_interface.net-interface]
  network_interface {
    network_interface_id = aws_network_interface.net-interface.id
    device_index         = 0
  }
  root_block_device {
    volume_size           = 20         
  }
  tags = {
    Name = "jenkins-terraform"
    environment = "dev"
  }
}
