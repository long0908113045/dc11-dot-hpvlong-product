resource "aws_security_group" "devops_rds_security_group" {
  name_prefix = "rds-"
  vpc_id      = data.terraform_remote_state.dc11-dot-hpvlong-product-terraform-state.outputs.devops_vpc_id.id

  // Define your inbound and outbound rules as needed
  // Example: Allow MySQL traffic from the EC2 instance
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.dc11-dot-hpvlong-product-terraform-state.outputs.devops_private_subnets[0].cidr_block] # Assuming the first private subnet
  }
  tags = {
    Name = "devops_rds_security_group"
  }
}

resource "aws_db_subnet_group" "devops_my_db_subnet_group" {
  name       = "my-db-subnet-group"
  description = "My DB Subnet Group"

  subnet_ids = data.terraform_remote_state.dc11-dot-hpvlong-product-terraform-state.outputs.devops_private_subnets[*].id
  tags = {
    Name = "devops_my_db_subnet_group"
  }
}

resource "aws_db_instance" "devops_rds" {
  allocated_storage    = 5 # Minimum allocated storage
  storage_type         = "standard" # SSD storage
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro" # Smallest possible size
  db_name              = "mydb"
  username             = "admin"
  password             = "123456789"
  skip_final_snapshot  = true
  multi_az             = false # Multi-AZ: none
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.devops_rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.devops_my_db_subnet_group.name

  tags = {
    Name = "devops_rds"
  }
}