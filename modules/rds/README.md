## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0, < 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72.0, < 5 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.test_bf_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.test_bf_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | GBs of storage for RDS instance | `number` | `30` | no |
| <a name="input_autoscaling_group_sg_id"></a> [autoscaling\_group\_sg\_id](#input\_autoscaling\_group\_sg\_id) | Security group of the nginx web service using autoscaling group of ec2 instances | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | RDS database name | `string` | n/a | yes |
| <a name="input_engine"></a> [engine](#input\_engine) | Engine to be used by RDS | `string` | `"postgres"` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Compute class for RDS instance | `string` | `"db.t3.micro"` | no |
| <a name="input_keepers"></a> [keepers](#input\_keepers) | Arbitrary map of values that, when changed, will trigger recreation of resource. | `map(string)` | <pre>{<br>  "pass_version": 1<br>}</pre> | no |
| <a name="input_min_special"></a> [min\_special](#input\_min\_special) | The minimum number of special characters in the master password. | `number` | `5` | no |
| <a name="input_override_special"></a> [override\_special](#input\_override\_special) | Supply your own list of special characters to use for string generation. | `string` | `"!#$^&*()-_=[]{}<>:?"` | no |
| <a name="input_rds_name_prefix"></a> [rds\_name\_prefix](#input\_rds\_name\_prefix) | RDS name prefix to use for all related resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy the resources | `string` | `"us-east-1"` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | RDS storage type to use | `string` | `"gp2"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | IDs of the private subnets to be used by RDS | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | RDS username | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to be used for RDS related resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | The RDS postgres endpoint |
| <a name="output_rds_user"></a> [rds\_user](#output\_rds\_user) | The master user credentials |
