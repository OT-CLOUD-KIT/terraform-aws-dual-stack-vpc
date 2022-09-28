resource "aws_vpc" "this" {
  cidr_block                           = var.vpc_cidr_block
  instance_tenancy                     = var.vpc_instance_tenancy
  enable_dns_support                   = var.vpc_enable_dns_support
  enable_dns_hostnames                 = var.vpc_enable_dns_hostnames
  assign_generated_ipv6_cidr_block     = var.vpc_assign_generated_ipv6_cidr_block
  ipv4_ipam_pool_id                    = var.vpc_ipv4_ipam_pool_id
  ipv4_netmask_length                  = var.vpc_ipv4_netmask_length
  ipv6_cidr_block                      = var.vpc_ipv6_cidr_block
  ipv6_ipam_pool_id                    = var.vpc_ipv6_ipam_pool_id
  ipv6_netmask_length                  = var.vpc_ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.vpc_ipv6_cidr_block_network_border_group
  tags = merge({
    Name = var.vpc_name
  }, var.tags)
}

resource "aws_subnet" "private" {
  for_each                                       = var.vpc_and_more ? (var.vpc_assign_generated_ipv6_cidr_block ? (var.ipv6_native ? { for k, v in local.native_iteratable_list_azs_ipv6_cdirs : k => v } : { for k, v in local.iteratable_list_azs_4_6_cdirs : k => v }) : { for k, v in local.iteratable_list_azs_cdirs : k => v }) : {}
  vpc_id                                         = aws_vpc.this.id
  cidr_block                                     = var.ipv6_native ? null : each.value.ipv4_cidr
  availability_zone                              = each.value.az
  assign_ipv6_address_on_creation                = var.ipv6_native ? true : var.assign_ipv6_address_on_creation
  enable_dns64                                   = var.vpc_assign_generated_ipv6_cidr_block ? true : var.enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = var.ipv6_native ? true : var.enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = var.enable_resource_name_dns_a_record_on_launch
  ipv6_cidr_block                                = var.vpc_assign_generated_ipv6_cidr_block ? each.value.ipv6_cidr : null
  ipv6_native                                    = var.ipv6_native
  map_public_ip_on_launch                        = var.map_public_ip_on_launch
  private_dns_hostname_type_on_launch            = var.ipv6_native ? "resource-name" : var.private_dns_hostname_type_on_launch

  tags = merge({
    Name = format("%s-subnet-private%d-%s", var.vpc_name, each.key + 1, each.value.az)
  }, var.tags)
}

resource "aws_subnet" "public" {
  for_each                                       = var.vpc_and_more ? (var.vpc_assign_generated_ipv6_cidr_block ? (var.ipv6_native ? { for k, v in local.pub_native_iteratable_list_azs_ipv6_cdirs : k => v } : { for k, v in local.pub_iteratable_list_azs_4_6_cdirs : k => v }) : { for k, v in local.iteratable_list_azs_cdirs : k => v }) : {}
  vpc_id                                         = aws_vpc.this.id
  cidr_block                                     = var.ipv6_native ? null : each.value.ipv4_cidr
  availability_zone                              = each.value.az
  assign_ipv6_address_on_creation                = var.ipv6_native ? true : var.assign_ipv6_address_on_creation
  enable_dns64                                   = var.vpc_assign_generated_ipv6_cidr_block ? true : var.enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = var.ipv6_native ? true : var.enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = var.enable_resource_name_dns_a_record_on_launch
  ipv6_cidr_block                                = var.vpc_assign_generated_ipv6_cidr_block ? each.value.ipv6_cidr : null
  ipv6_native                                    = var.ipv6_native
  map_public_ip_on_launch                        = var.ipv6_native ? false : var.pub_map_public_ip_on_launch
  private_dns_hostname_type_on_launch            = var.ipv6_native ? "resource-name" : var.private_dns_hostname_type_on_launch

  tags = merge({
    Name = format("%s-subnet-public%d-%s", var.vpc_name, each.key + 1, each.value.az)
  }, var.tags)
}

resource "aws_route_table" "private" {
  count  = var.vpc_and_more && var.number_of_azs_private_subnets.num_private_subnets != 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = format("%s-rtb-private", var.vpc_name)
  }, var.tags)
}

resource "aws_route_table" "public" {
  count  = var.vpc_and_more && var.number_of_azs_private_subnets.num_public_subnets != 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = format("%s-rtb-public", var.vpc_name)
  }, var.tags)
}

resource "aws_route_table_association" "private" {
  for_each       = var.vpc_and_more && var.number_of_azs_private_subnets.num_private_subnets != 0 ? { for k, v in aws_subnet.private : k => v } : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
  depends_on = [
    aws_subnet.private
  ]
}
resource "aws_route_table_association" "public" {
  for_each       = var.vpc_and_more && var.number_of_azs_private_subnets.num_public_subnets != 0 ? { for k, v in aws_subnet.public : k => v } : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_internet_gateway" "igw" {
  count  = var.vpc_and_more && var.number_of_azs_private_subnets.num_public_subnets != 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = format("%s-igw", var.vpc_name)
  }, var.tags)
}

resource "aws_nat_gateway" "ngw" {
  count         = var.vpc_and_more && var.create_nat_gateway && var.number_of_azs_private_subnets.num_public_subnets != 0 && var.ipv6_native == false ? 1 : 0
  allocation_id = aws_eip.nat_allocation[0].id
  subnet_id     = [for a in aws_subnet.public : a.id][0]
  tags = merge({
    Name = format("%s-nat-gateway", var.vpc_name)
  }, var.tags)
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_allocation" {
  count      = var.vpc_and_more && var.create_nat_gateway && var.number_of_azs_private_subnets.num_public_subnets != 0 && var.ipv6_native == false ? 1 : 0
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_egress_only_internet_gateway" "egress_gw" {
  count  = var.vpc_and_more && var.vpc_assign_generated_ipv6_cidr_block && var.number_of_azs_private_subnets.num_public_subnets != 0 && var.enable_egress_igw ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = format("%s-egress-only-gw", var.vpc_name)
  }, var.tags)
}

resource "aws_route" "assign_ngw_route_ipv4" {
  count                  = var.vpc_and_more && var.create_nat_gateway && var.number_of_azs_private_subnets.num_public_subnets != 0 && var.ipv6_native != true ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[0].id
}

resource "aws_route" "assign_igw_route_ipv4" {
  count                  = var.vpc_and_more && var.number_of_azs_private_subnets.num_public_subnets != 0 && var.ipv6_native != true ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route" "assign_igw_route_ipv6" {
  count                  = var.vpc_and_more && var.number_of_azs_private_subnets.num_public_subnets != 0 && var.vpc_assign_generated_ipv6_cidr_block ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}
resource "aws_route" "assign_egress_igw_route_ipv6" {
  count                  = var.vpc_and_more && var.number_of_azs_private_subnets.num_public_subnets != 0 && var.vpc_assign_generated_ipv6_cidr_block && var.enable_egress_igw ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id             = aws_egress_only_internet_gateway.egress_gw[0].id
}