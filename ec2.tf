provider "aws" {
 region = "us-east-1"
}

data "aws_region" "current"{}

# Using default VPC 
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "existing_sg" {
  name = "DockerSG"
  # Alternatively, you can use the `id` argument to specify the ID of the security group.
  # id = "sg-0123456789abcdef0"
}

# Creating security group for the EC2 instance
#resource "aws_security_group" "ec2-SG" {
  #name   = "ec2-SG"
  #vpc_id = data.aws_vpc.default.id

  # HTTP access from anywhere
  #ingress {
    #from_port   = 80
    #to_port     = 80
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}

  # HTTPS access from anywhere
  #ingress {
    #from_port   = 443
    #to_port     = 443
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}

  # SSH access from anywhere
  #ingress {
    #from_port   = 22
    #to_port     = 22
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}

  #egress {
    #from_port   = 0
    #to_port     = 0
    #protocol    = "-1"
    #cidr_blocks = ["0.0.0.0/0"]
  #}

  #tags = {
    #name = "PublicSG"
  #}
#}

#resource "aws_internet_gateway" "vpc_igw" {
  #vpc_id = data.aws_vpc.default.id

  #tags = {
   # Name = "VPC_IGW"
  #}
#}

# Reference the default subnet in the default VPC
data "aws_subnet" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Route table
 resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0ad8e1b6f54446250"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = "igw-0ad8e1b6f54446250"
  }

  tags = {
    Name = "PublicRT"
  }
}

# Route Table Association
resource "aws_route_table_association" "rta_public" {
  subnet_id      = "subnet-0a51813fd0a961709"
  route_table_id = aws_route_table.public_rt.id
}

# AMI to be referenced in the EC2
#data "aws_ssm_parameter" "instance_ami" {
  #name = "amazon/ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230919"
#}

# Keypair to be referenced in the EC2
data "aws_key_pair" "cba_keypair1" {
  key_name = "cba_keypair1"
}

#resource "aws_instance" "ec2_spin" {
  #ami                         = data.aws_ssm_parameter.instance_ami.value
  #instance_type               = "t2.medium"
  #key_name                    = data.aws_key_pair.cba_keypair1
  #iam_instance_profile        = aws_iam_instance_profile.session-manager.id
  #associate_public_ip_address = true
  #security_groups            = ["aws_security_group.public_sgpblb"]
  #subnet_id                   = "aws_subnet.cba_public1.id"
  #user_data       = fileexists("docker-compose.yml") ? file("docker-compose.yml") : null
  #tags = {
    #Name = "Bastion"
  #}
#}

resource "aws_instance" "ec2_spin" {
  ami           = "ami-0fc5d935ebf8bc3bc"  
  instance_type = "t3.medium"              
  key_name      = "cba_keypair1" 
  subnet_id     = "subnet-0a51813fd0a961709"  # "subnet-0123456789abcdef0"  # Replace with your desired subnet ID
  associate_public_ip_address = true
  security_groups = [data.aws_security_group.existing_sg.id]
  user_data       = fileexists("user_dataJen.sh") ? file("user_dataJen.sh") : null
  
  tags = {
    Name = "ec2_spin"
  }
}