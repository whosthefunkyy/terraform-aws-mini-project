
provider "aws" {
  region = "ap-southeast-1"
}
 terraform {
  backend "s3" {
    bucket = "your-bucket-name"
    key    = "dev/network/terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
 }

data "aws_availability_zones" "available" {}
 
 resource "aws_vpc" "main" {
   cidr_block = var.vpc_cidr

    tags = {
      Name = "${var.env}-vpc"
    }
 }

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index] 
  map_public_ip_on_launch = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.env}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
   }
   tags = {
      Name = "${var.env}-public-rt"
   }
}
resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}


 resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.main.id

   tags = {
     Name = "${var.env}-igw"
   }
 }
