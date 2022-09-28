locals {
  max_number_of_azs              = length(var.number_of_azs_private_subnets.customize_azs) == 0 ? var.number_of_azs_private_subnets.num_azs : length(var.number_of_azs_private_subnets.customize_azs)
  number_of_privte_subnet        = var.number_of_azs_private_subnets.num_private_subnets
  count_azs                      = length(var.number_of_azs_private_subnets.customize_azs) == 0 ? slice(data.aws_availability_zones.available.names, 0, local.max_number_of_azs) : var.number_of_azs_private_subnets.customize_azs
  calc_num_private_subnet_per_az = local.number_of_privte_subnet != 0 ? local.number_of_privte_subnet / local.max_number_of_azs : 0
  calc_cidrs                     = local.calc_num_private_subnet_per_az != 0 ? range(length(local.count_azs) * local.calc_num_private_subnet_per_az) : []
  generate_private_cidrs_list    = [for i in local.calc_cidrs : cidrsubnet(aws_vpc.this.cidr_block, 4, 8 + i)]
  split_cidrs                    = chunklist(local.generate_private_cidrs_list, local.calc_num_private_subnet_per_az)
  associate_cidr_with_azs        = length(local.split_cidrs) != 0 ? zipmap(local.count_azs, local.split_cidrs) : {}
  iteratable_list_azs_cdirs      = flatten([for member, value in local.associate_cidr_with_azs : [for subnet in value : {
    az        = member
    ipv4_cidr = subnet
  }]])

  ### IPv6 locals #################
  generate_ipv6_cidr_list = var.vpc_assign_generated_ipv6_cidr_block ? [for i in local.calc_cidrs : cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 100 + i)] : null
  combine_both_cidrs_4_6  = var.vpc_assign_generated_ipv6_cidr_block ? zipmap(local.generate_private_cidrs_list, local.generate_ipv6_cidr_list) : null
  create_list_ipv_4_6_cidrs = var.vpc_assign_generated_ipv6_cidr_block ? [for k, v in local.combine_both_cidrs_4_6 : {
    ipv4_cidr = k
    ipv6_cidr = v
  }] : null
  split_cidrs_into_parts      = var.vpc_assign_generated_ipv6_cidr_block ? chunklist(local.create_list_ipv_4_6_cidrs, local.calc_num_private_subnet_per_az) : null
  associate_cidrs_4_6_with_az = var.vpc_assign_generated_ipv6_cidr_block ? zipmap(local.count_azs, local.split_cidrs_into_parts) : null
  iteratable_list_azs_4_6_cdirs = var.vpc_assign_generated_ipv6_cidr_block ? flatten([for member, value in local.associate_cidrs_4_6_with_az : [for subnet in value : {
    az        = member
    ipv4_cidr = subnet.ipv4_cidr
    ipv6_cidr = subnet.ipv6_cidr
  }]]) : null

  native_split_ipv6cidrs             = var.vpc_assign_generated_ipv6_cidr_block ? chunklist(local.generate_ipv6_cidr_list, local.calc_num_private_subnet_per_az) : null
  native_associate_ipv6_cidr_with_az = var.vpc_assign_generated_ipv6_cidr_block ? zipmap(local.count_azs, local.native_split_ipv6cidrs) : null
  native_iteratable_list_azs_ipv6_cdirs = var.vpc_assign_generated_ipv6_cidr_block ? flatten([for member, value in local.native_associate_ipv6_cidr_with_az : [for subnet in value : {
    az        = member
    ipv6_cidr = subnet
  }]]) : null

  ####public subnets local definition#########

  number_of_public_subnets       = var.number_of_azs_private_subnets.num_public_subnets
  calc_num_public_subnet_per_az  = local.number_of_public_subnets != 0 ? local.number_of_public_subnets / local.max_number_of_azs : 0
  pub_calc_cidrs                 = local.calc_num_public_subnet_per_az != 0 ? range(length(local.count_azs) * local.calc_num_public_subnet_per_az) : []
  pub_generate_public_cidrs_list = [for i in local.pub_calc_cidrs : cidrsubnet(aws_vpc.this.cidr_block, 4, i)]
  pub_split_cidrs                = chunklist(local.pub_generate_public_cidrs_list, local.calc_num_public_subnet_per_az)
  pub_associate_cidr_with_azs    = length(local.pub_split_cidrs) != 0 ? zipmap(local.count_azs, local.pub_split_cidrs) : {}
  pub_iteratable_list_azs_cdirs = flatten([for member, value in local.pub_associate_cidr_with_azs : [for subnet in value : {
    az        = member
    ipv4_cidr = subnet
  }]])

  ############ IPv6 Public Access ############
  pub_generate_ipv6_cidr_list = var.vpc_assign_generated_ipv6_cidr_block ? [for i in local.pub_calc_cidrs : cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, i)] : null
  pub_combine_both_cidrs_4_6  = var.vpc_assign_generated_ipv6_cidr_block ? zipmap(local.pub_generate_public_cidrs_list, local.pub_generate_ipv6_cidr_list) : null
  pub_create_list_ipv_4_6_cidrs = var.vpc_assign_generated_ipv6_cidr_block ? [for k, v in local.pub_combine_both_cidrs_4_6 : {
    ipv4_cidr = k
    ipv6_cidr = v
  }] : null
  pub_split_cidrs_into_parts      = var.vpc_assign_generated_ipv6_cidr_block ? chunklist(local.pub_create_list_ipv_4_6_cidrs, local.calc_num_public_subnet_per_az) : null
  pub_associate_cidrs_4_6_with_az = var.vpc_assign_generated_ipv6_cidr_block ? zipmap(local.count_azs, local.pub_split_cidrs_into_parts) : null
  pub_iteratable_list_azs_4_6_cdirs = var.vpc_assign_generated_ipv6_cidr_block ? flatten([for member, value in local.pub_associate_cidrs_4_6_with_az : [for subnet in value : {
    az        = member
    ipv4_cidr = subnet.ipv4_cidr
    ipv6_cidr = subnet.ipv6_cidr
  }]]) : null
  pub_native_split_ipv6cidrs             = var.vpc_assign_generated_ipv6_cidr_block ? chunklist(local.pub_generate_ipv6_cidr_list, local.calc_num_public_subnet_per_az) : null
  pub_native_associate_ipv6_cidr_with_az = var.vpc_assign_generated_ipv6_cidr_block ? zipmap(local.count_azs, local.pub_native_split_ipv6cidrs) : null
  pub_native_iteratable_list_azs_ipv6_cdirs = var.vpc_assign_generated_ipv6_cidr_block ? flatten([for member, value in local.pub_native_associate_ipv6_cidr_with_az : [for subnet in value : {
    az        = member
    ipv6_cidr = subnet
  }]]) : null

}