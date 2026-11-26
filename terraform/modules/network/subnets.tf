data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private[0]
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private[1]
  availability_zone = data.aws_availability_zones.available.names[1]
}


resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_public[0]
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_public[1]
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "internal_alb" {
  count             = length(var.internal_alb_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.internal_alb_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                              = "${var.env}-internal-alb-${count.index}"
    Env                               = var.env
    "kubernetes.io/role/internal-elb" = "1"
  }
}