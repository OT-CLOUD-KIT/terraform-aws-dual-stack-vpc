######### VPC Variables #######################
variable "vpc_name" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "vpc_instance_tenancy" {
  type    = string
  default = "default"
}
variable "vpc_enable_dns_support" {
  type    = bool
  default = true
}
variable "vpc_enable_dns_hostnames" {
  type    = bool
  default = true
}
variable "vpc_assign_generated_ipv6_cidr_block" {
  type    = bool
  default = false
}
variable "vpc_ipv4_ipam_pool_id" {
  type    = string
  default = null
}
variable "vpc_ipv4_netmask_length" {
  type    = string
  default = null
}
variable "vpc_ipv6_cidr_block" {
  type    = string
  default = null
}
variable "vpc_ipv6_ipam_pool_id" {
  type    = string
  default = null
}
variable "vpc_ipv6_netmask_length" {
  type    = string
  default = null
}
variable "vpc_ipv6_cidr_block_network_border_group" {
  type    = string
  default = null
}
variable "tags" {
  type    = map(any)
  default = {}
}


########### private subnet variables ####################

# variable "vpc_id" {
#   type = string
# }
variable "vpc_and_more" {
  type    = bool
  default = false
}
variable "customize_azs" {
  type    = list(string)
  default = null
}
variable "availability_zone" {
  type    = list(any)
  default = null
}
variable "assign_ipv6_address_on_creation" {
  type    = bool
  default = false
}
variable "enable_dns64" {
  type    = bool
  default = false
}
variable "enable_resource_name_dns_aaaa_record_on_launch" {
  type    = bool
  default = false
}
variable "enable_resource_name_dns_a_record_on_launch" {
  type    = bool
  default = false
}
variable "ipv6_cidr_block" {
  type    = string
  default = null
}
variable "ipv6_native" {
  type    = bool
  default = false
}
variable "map_public_ip_on_launch" {
  type    = bool
  default = false
}
variable "private_dns_hostname_type_on_launch" {
  type    = string
  default = "ip-name"
}
variable "region" {
  default = null
}

variable "number_of_azs_private_subnets" {
  type = object(
    {
      num_azs             = number
      num_private_subnets = number
      num_public_subnets  = number
      customize_azs       = list(string)
    }
  )
  default = {
    customize_azs       = []
    num_azs             = 2
    num_public_subnets  = 2
    num_private_subnets = 2
  }
  validation {
    condition     = contains([1, 2, 3], var.number_of_azs_private_subnets.num_azs)
    error_message = "Max number of azs allowed is 3."
  }
  validation {
    condition     = contains(length(var.number_of_azs_private_subnets.customize_azs) == 0 ? (var.number_of_azs_private_subnets.num_azs == 3 ? range(0, var.number_of_azs_private_subnets.num_azs + 6, 3) : var.number_of_azs_private_subnets.num_azs == 2 ? range(0, var.number_of_azs_private_subnets.num_azs + 3, 2) : range(var.number_of_azs_private_subnets.num_azs + 2)) : (length(var.number_of_azs_private_subnets.customize_azs) == 3 ? range(0, length(var.number_of_azs_private_subnets.customize_azs) + 6, 3) : length(var.number_of_azs_private_subnets.customize_azs) == 2 ? range(0, length(var.number_of_azs_private_subnets.customize_azs) + 3, 2) : range(length(var.number_of_azs_private_subnets.customize_azs) + 2)), var.number_of_azs_private_subnets.num_private_subnets)
    error_message = "Number of private subnet values depends on number of azs, like if azs value is 2 then number of private subnets will be 0,2,4."
  }
  validation {
    condition     = contains(length(var.number_of_azs_private_subnets.customize_azs) == 0 ? (var.number_of_azs_private_subnets.num_azs == 3 ? range(0, var.number_of_azs_private_subnets.num_azs + 3, 3) : var.number_of_azs_private_subnets.num_azs == 2 ? range(0, var.number_of_azs_private_subnets.num_azs + 2, 2) : range(var.number_of_azs_private_subnets.num_azs + 1)) : (length(var.number_of_azs_private_subnets.customize_azs) == 3 ? range(0, length(var.number_of_azs_private_subnets.customize_azs) + 3, 3) : length(var.number_of_azs_private_subnets.customize_azs) == 2 ? range(0, length(var.number_of_azs_private_subnets.customize_azs) + 2, 2) : range(length(var.number_of_azs_private_subnets.customize_azs) + 1)), var.number_of_azs_private_subnets.num_public_subnets)
    error_message = "Number of Public subnet values depends on number of azs, like if azs value is eq to 2 then number of public subnets will be 0,2."
  }
}


#### Public subnet variables #######################

# variable "pub_assign_ipv6_address_on_creation" {
#   type    = bool
#   default = false
# }
# variable "pub_enable_dns64" {
#   type    = bool
#   default = false
# }
# variable "pub_enable_resource_name_dns_aaaa_record_on_launch" {
#   type    = bool
#   default = false
# }
# variable "pub_enable_resource_name_dns_a_record_on_launch" {
#   type    = bool
#   default = false
# }
# variable "pub_ipv6_cidr_block" {
#   type    = string
#   default = null
# }
# variable "pub_ipv6_native" {
#   type    = bool
#   default = false
# }
variable "pub_map_public_ip_on_launch" {
  type    = bool
  default = true
}
variable "pub_private_dns_hostname_type_on_launch" {
  type    = string
  default = "ip-name"
}

variable "create_nat_gateway" {
  type    = bool
  default = false
}
variable "enable_egress_igw" {
  default= false
}