# resource "aws_vpc" "unity-test-env" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support = true
#   tags = {
#     Name = "unity-test-env"
#     Deployment = "unity-demo"
#   }
# }

resource "aws_subnet" "subnet-uno" {
  cidr_block        = cidrsubnet(data.aws_vpc.unity-test-env.cidr_block, 3, 1)
  vpc_id            = data.aws_vpc.unity-test-env.id
  availability_zone = "us-west-2a"
  tags = {
    Deployment = "unity-demo"
  }
}

resource "aws_subnet" "subnet-two" {
  cidr_block        = cidrsubnet(data.aws_vpc.unity-test-env.cidr_block, 4, 1)
  vpc_id            = data.aws_vpc.unity-test-env.id
  availability_zone = "us-west-2b"
  tags = {
    Deployment = "unity-demo"
  }
}

resource "aws_route_table" "route-table-test-env" {
  vpc_id = data.aws_vpc.unity-test-env.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-env-gw.id
  }
  tags = {
    Name       = "test-env-route-table"
    Deployment = "unity-demo"

  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet-uno.id
  route_table_id = aws_route_table.route-table-test-env.id
  # tags = {
  #   Deployment = "unity-demo"
  # }
}

resource "aws_route_table_association" "subnet-association2" {
  subnet_id      = aws_subnet.subnet-two.id
  route_table_id = aws_route_table.route-table-test-env.id
  # tags = {
  #   Deployment = "unity-demo"
  # }
}