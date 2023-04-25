output "aws_alb_arn" {
  description = "AWS ALB arn"
  value       = aws_lb.test_bf_alb.arn
}

output "aws_asg_sg_id" {
  description = "AWS Autoscaling group SG id"
  value       = aws_security_group.test_bf_asg_sg.id
}