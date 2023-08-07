data "aws_ami" "al2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # Amazon
}

resource "aws_launch_template" "bastion" {
  name_prefix   = "bastion"
  image_id      = data.aws_ami.al2.id
  instance_type = "t2.micro"

  key_name = var.public_key

  vpc_security_group_ids = [aws_security_group.security_group.id]

  user_data = base64encode(<<EOF
#!/bin/bash
sudo yum install ec2-instance-connect
wget https://golang.org/dl/go1.20.7.linux-amd64.tar.gz
tar -xvf go1.20.7.linux-amd64.tar.gz
mv go /usr/local
echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
source /etc/profile
EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "bastion" {
  count         = var.create_IP ? 1 : 0
  ami           = data.aws_ami.al2.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id              = aws_subnet.public.id

  associate_public_ip_address = true

  user_data = base64encode(<<EOF
#!/bin/bash
sudo yum install ec2-instance-connect
wget https://golang.org/dl/go1.20.7.linux-amd64.tar.gz
tar -xvf go1.20.7.linux-amd64.tar.gz
mv go /usr/local
echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
source /etc/profile
EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "ip" {
  count = var.create_IP ? 1 : 0
  vpc   = true
}

resource "aws_eip_association" "bastion" {
  count         = var.create_IP ? 1 : 0
  instance_id   = aws_instance.bastion[count.index].id
  allocation_id = aws_eip.ip[count.index].id
}