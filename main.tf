provider "aws" {
  region = var.aws_region

}
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
resource "aws_subnet" "sub-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet-1_cidr
  tags = {
    Name = var.subnet-1_name
  }

}
resource "aws_subnet" "sub-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet-2_cidr
  tags = {
    Name = var.subnet-2_name
  }

}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.igw_name
  }

}
resource "aws_default_route_table" "rtb" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.route_name
  }
}
resource "aws_route_table_association" "link-1" {
  route_table_id = aws_default_route_table.rtb.id
  subnet_id      = aws_subnet.sub-1.id

}
resource "aws_route_table_association" "link-2" {
  route_table_id = aws_default_route_table.rtb.id
  subnet_id      = aws_subnet.sub-2.id

}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "role" {
  name               = "test-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.role.name

}
resource "aws_security_group" "Allow" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = var.security_group_name
  }
}
resource "aws_instance" "ec2-main" {
  ami                    = "ami-0fa91bc90632c73c9"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sub-1.id
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  vpc_security_group_ids = [aws_security_group.Allow.id]
  tags = {
    Name = var.ec2_name
  }
}