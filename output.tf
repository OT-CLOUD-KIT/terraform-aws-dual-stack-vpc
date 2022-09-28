output "vpc" {
  value = aws_vpc.this
}
output "subnet_private" {
  value = aws_subnet.private
}
output "subnet_public" {
  value = aws_subnet.public
}
output "public_rtb" {
  value = aws_route_table.public
}
output "private_rtb" {
  value = aws_route_table.private
}
output "private_subnet_ids" {
  value = [for a in aws_subnet.private : a.id]
}
output "public_subnet_ids" {
  value = [for a in aws_subnet.public : a.id]
}
output "public_rtb_id" {
  value = var.vpc_and_more && var.number_of_azs_private_subnets.num_public_subnets != 0 ? aws_route_table.public[0].id : null
}
output "private_rtb_id" {
  value = var.vpc_and_more && var.number_of_azs_private_subnets.num_private_subnets != 0 ? aws_route_table.private[0].id : null
}

output "igw_id" {
  value = var.vpc_and_more && var.number_of_azs_private_subnets.num_public_subnets != 0 ? aws_internet_gateway.igw[0].id : null
}

output "ngw_id" {
  value = var.vpc_and_more && var.create_nat_gateway && var.number_of_azs_private_subnets.num_public_subnets != 0 && var.ipv6_native == false ? aws_nat_gateway.ngw[0].id : null
}
# output "transit_gateway_subnet_ids" {
#   value = [for k, v in data.aws_subnets.private : v.ids[0]]
# }