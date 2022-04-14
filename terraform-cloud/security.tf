resource "aws_security_group" "ingress-all-test" {
  name   = "allow-all-sg"
  vpc_id = data.aws_vpc.unity-test-env.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 16443
    to_port   = 16443
    protocol  = "tcp"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 25000
    to_port   = 25000
    protocol  = "tcp"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Deployment = "unity-demo"
  }
}

resource "aws_security_group" "redis_sg" {
  name   = "redis-sg"
  vpc_id = data.aws_vpc.unity-test-env.id

  ingress {
    protocol  = "tcp"
    from_port = "6379"
    to_port   = "6379"
    #cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
    security_groups = [aws_security_group.ingress-all-test.id]
  }
  ingress {
    from_port   = "6379"
    to_port     = "6379"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "es" {
  name        = "elasticsearch-sg"
  description = "Managed by Terraform"
  vpc_id      = data.aws_vpc.unity-test-env.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ingress-all-test.id]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Deployment = "unity-demo"
  }
}