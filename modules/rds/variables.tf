variable "instance_class" {
  description = "Compute class for RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "engine" {
  description = "Engine to be used by RDS"
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "allocated_storage" {
  description = "GBs of storage for RDS instance"
  type        = number
  default     = 30
}

variable "storage_type" {
  description = "RDS storage type to use"
  type        = string
  default     = "gp2"
}

variable "username" {
  description = "RDS username"
  type        = string
}

variable "rds_name_prefix" {
  description = "RDS name prefix to use for all related resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC to be used for RDS related resources"
  type        = string
}

variable "autoscaling_group_sg_id" {
  description = "Security group of the nginx web service using autoscaling group of ec2 instances"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the private subnets to be used by RDS"
  type        = list(string)
}

variable "region" {
  description = "AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "min_special" {
  description = "The minimum number of special characters in the master password."
  type        = number
  default     = 5
}

variable "override_special" {
  description = "Supply your own list of special characters to use for string generation."
  type        = string
  default     = "!#$^&*()-_=[]{}<>:?"
}

variable "keepers" {
  description = "Arbitrary map of values that, when changed, will trigger recreation of resource."
  type        = map(string)
  default = {
    pass_version = 1
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}