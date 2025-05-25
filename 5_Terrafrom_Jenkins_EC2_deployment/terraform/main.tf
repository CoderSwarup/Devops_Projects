locals {
  ami_id = "ami-0e35ddab05955cf57"
  instances = {
    instance1 = {
      ami           = local.ami_id
      instance_type = "t2.micro"
    }
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ec2-key"
  public_key = var.public_key
}

resource "aws_instance" "this" {
  for_each                    = local.instances
  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = each.key
  }
}
