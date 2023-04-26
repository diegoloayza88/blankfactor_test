# Blankfactor
AWS and Terraform code for Blankfactor Test

---
Test Description
-
* Create a nginx web service that utilizes multi-AZ in AWS. This Web service must only be accessible from NAB's public IPs (using your current public IP is also fine)
* Create an RDS server that's accessible to the web servers. All configurations must be as secure as possible (think of what you need to do to make everything secure).
* The web server needs to scale on-demand; when CPU load hits 65% or higher it needs to scale up, when it's 40% or lower it needs to scale down.
* All infrastructure components must be created using Terraform.

---
I've created a folder structure with the following:

modules/
* networking
.- All vpc resources are part of it
* rds
.- All rds resources are part of it
* web
.- All nginx resources like autoscaling group, load balancer, etc
are part of it

The consuming stack is within blankfactor_test folder, and basically
it's calling the respective modules and variables to be able to deploy the
aws services and resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.2.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>3.75 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_rds_db"></a> [rds\_db](#module\_rds\_db) | ./modules/rds | n/a |
| <a name="module_web_layer"></a> [web\_layer](#module\_web\_layer) | ./modules/web | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones names or ids in the region | `list(string)` | `[]` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | `string` | `""` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | RDS database name | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Image to use for the ec2 instances that will run nginx. | `string` | `"ami-0c55b159cbfafe1f0"` | no |
| <a name="input_my_ip_address"></a> [my\_ip\_address](#input\_my\_ip\_address) | My current ip address to be used to communicate with the ELB (restricted access to just only my IP) | `string` | n/a | yes |
| <a name="input_rds_name_prefix"></a> [rds\_name\_prefix](#input\_rds\_name\_prefix) | RDS name prefix to use for all related resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy the resources | `string` | `"us-east-1"` | no |
| <a name="input_username"></a> [username](#input\_username) | RDS username | `string` | n/a | yes |
| <a name="input_web_name_prefix"></a> [web\_name\_prefix](#input\_web\_name\_prefix) | Name to be used on every web layer related resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | The RDS postgres endpoint |
