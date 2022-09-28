data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "private" {
  for_each = toset(local.count_azs)

  filter {
    name   = "vpc-id"
    values = [aws_vpc.this.id]
  }
  filter {
    name   = "availability-zone"
    values = ["${each.value}"]
  }
}