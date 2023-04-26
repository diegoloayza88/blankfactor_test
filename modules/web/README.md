## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>3.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>3.75 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_listener.test_bf_alb_listener_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_autoscaling_group.test_bf_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.test_bf_asg_scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.test_bf_asg_scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_metric_alarm.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.test_bf_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.test_bf_instance_profile_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.test_bf_instance_profile_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.test_bf_instance_profile_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.test_bf_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.test_bf_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_target_group.test_bf_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.test_bf_alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.test_bf_asg_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_acm_certificate.interview27_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [local_file.user_data](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | EC2 image id to use | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t3.micro"` | no |
| <a name="input_my_ip_address"></a> [my\_ip\_address](#input\_my\_ip\_address) | My current ip address to be used to communicate with the ELB (restricted access to just only my IP) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy the resources | `string` | `"us-east-1"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | IDs of the private subnets to be used by RDS | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to be used for RDS related resources | `string` | n/a | yes |
| <a name="input_web_name_prefix"></a> [web\_name\_prefix](#input\_web\_name\_prefix) | Nginx WEB name prefix to use for all related resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_alb_arn"></a> [aws\_alb\_arn](#output\_aws\_alb\_arn) | AWS ALB arn |
| <a name="output_aws_asg_sg_id"></a> [aws\_asg\_sg\_id](#output\_aws\_asg\_sg\_id) | AWS Autoscaling group SG id |
