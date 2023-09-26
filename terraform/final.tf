data "aws_ami" "al" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.1.20230912.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

data "aws_vpc" "default" {
  default = true
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.al.id
  instance_type = "t2.micro"

  key_name = "deployer-key"

  vpc_security_group_ids = [ aws_security_group.allow_ssh_http.id,aws_security_group.rds_sg.id ]
  
  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
EOF
}

resource "aws_db_instance" "rds_instance" {
 allocated_storage = 20
 identifier = "rds-terraform"
 engine = "mysql"
 engine_version = "8.0.34"
 instance_class = "db.t2.micro"
 username = "wordpressdb"
 password = "Unicorn4.21"
 publicly_accessible    = true
 skip_final_snapshot    = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "ExampleRDSServerInstance"
  }

}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
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

}

resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Security group for RDS instance"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
}

data "aws_instance" "web_instance" {
  instance_id = aws_instance.web.id
}

output "instance_ip_addr" {
  value = aws_instance.web.public_ip
}

data "aws_db_instance" "rds_ip" {
  db_instance_identifier = "rds-terraform"  # Replace with your RDS instance identifier
}

output "rds_instance_ip" {
  value = data.aws_db_instance.rds_ip.address
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
