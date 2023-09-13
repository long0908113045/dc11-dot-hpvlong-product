resource "aws_security_group" "devops_ec2_security_group" {
  name_prefix = "ec2-"
  vpc_id      = data.terraform_remote_state.dc11-dot-hpvlong-product-terraform-state.outputs.devops_vpc_id.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Define your inbound and outbound rules as needed
  // Example: Allow outbound traffic to the RDS instance
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.dc11-dot-hpvlong-product-terraform-state.outputs.devops_public_subnets[0].cidr_block]
  }
  tags = {
    Name = "devops_ec2_security_group"
  }
}

resource "aws_instance" "devops_ec2" {
  ami           = "ami-0df7a207adb9748c7" # ubuntu-jammy-22.04-amd64-server-20230516
  instance_type = "t2.micro" # Smallest possible size
  subnet_id     = data.terraform_remote_state.dc11-dot-hpvlong-product-terraform-state.outputs.devops_public_subnets[0].id # Assuming the first public subnet
  key_name = "devops"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10 # 10GB EBS
  }

  tags = {
    Name = "devops_ec2"
  }
}

resource "aws_eip" "devops_eip" {
  instance = aws_instance.devops_ec2.id
  tags = {
    Name = "devops_eip"
  }
}

# Associate EC2 security group with the EC2 instance
resource "aws_network_interface_sg_attachment" "devops_ec2_sg_attachment" {
  security_group_id    = aws_security_group.devops_ec2_security_group.id
  network_interface_id = aws_instance.devops_ec2.primary_network_interface_id
}
