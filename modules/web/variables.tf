variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "image_id" {
  description = "EC2 image id to use"
  type        = string
}

variable "target_value" {
  description = "Target value in second to trigger auto-scaling"
  type        = number
}

variable "web_name_prefix" {
  description = "Nginx WEB name prefix to use for all related resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC to be used for RDS related resources"
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}