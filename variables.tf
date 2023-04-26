variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = ""
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "rds_name_prefix" {
  description = "RDS name prefix to use for all related resources"
  type        = string
}

variable "web_name_prefix" {
  description = "Name to be used on every web layer related resource."
  type        = string
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "username" {
  description = "RDS username"
  type        = string
}

variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
  default     = "us-east-1"
}

variable "image_id" {
  type        = string
  description = "Image to use for the ec2 instances that will run nginx."
  default     = "ami-0c55b159cbfafe1f0"
}

variable "my_ip_address" {
  type        = string
  description = "My current ip address to be used to communicate with the ELB (restricted access to just only my IP)"
}