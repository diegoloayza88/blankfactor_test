################################################################################
# Launch Template
################################################################################

data "local_file" "user_data" {
  filename = "${path.module}/user_data.sh"
}

resource "aws_launch_template" "test_bf_launch_template" {
  name                   = "${var.web_name_prefix}-nginx-launch-template"
  instance_type          = var.instance_type
  update_default_version = true
  image_id               = var.image_id

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.test_bf_asg_sg.id]
    subnet_id                   = var.private_subnet_ids[0]
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 16
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.test_bf_instance_profile.name
  }

  user_data = base64encode(data.local_file.user_data.content)

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

################################################################################
# Autoscaling group (EC2 instances) security group
################################################################################

resource "aws_security_group" "test_bf_asg_sg" {
  name_prefix = "${var.web_name_prefix}-asg-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.test_bf_alb_sg.id]
  }

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

################################################################################
# IAM role and policy for instance profile
################################################################################
resource "aws_iam_role" "test_bf_instance_profile_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  name = "${var.web_name_prefix}-instance-profile-role"

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_iam_instance_profile" "test_bf_instance_profile" {
  name = "${var.web_name_prefix}-instance-profile"
  role = aws_iam_role.test_bf_instance_profile_role.name

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_iam_policy" "test_bf_instance_profile_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:DescribeAssociation",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      }
    ]
  })
  name = "${var.web_name_prefix}-instance-profile-policy"

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "test_bf_instance_profile_policy_attachment" {
  role       = aws_iam_role.test_bf_instance_profile_role.name
  policy_arn = aws_iam_policy.test_bf_instance_profile_policy.arn
}

################################################################################
# EC2 autoscaling group
################################################################################

resource "aws_autoscaling_group" "test_bf_asg" {
  name = "${var.web_name_prefix}-asg"
  launch_template {
    id      = aws_launch_template.test_bf_launch_template.id
    version = "$Latest"
  }
  target_group_arns         = [aws_lb_target_group.test_bf_tg.arn]
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 300
  max_size                  = 3
  min_size                  = 1
  termination_policies      = ["OldestInstance", "Default"]
}

resource "aws_autoscaling_policy" "test_bf_asg_scale_up" {
  autoscaling_group_name = aws_autoscaling_group.test_bf_asg.name
  name                   = "${var.web_name_prefix}-asg-scale-up-policy"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 180
}

resource "aws_autoscaling_policy" "test_bf_asg_scale_down" {
  autoscaling_group_name = aws_autoscaling_group.test_bf_asg.name
  name                   = "${var.web_name_prefix}-asg-scale-down-policy"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_description   = "Monitors CPU utilization Greater Than or Equal to 65% for Test Blankfactor ASG"
  alarm_actions       = [aws_autoscaling_policy.test_bf_asg_scale_up.arn]
  alarm_name          = "test_bf_asg_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "65"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.test_bf_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description   = "Monitors CPU utilization Less Than or Equal to 40% for Test Blankfactor ASG"
  alarm_actions       = [aws_autoscaling_policy.test_bf_asg_scale_down.arn]
  alarm_name          = "test_bf_asg_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "40"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.test_bf_asg.name
  }
}

################################################################################
# Application load balancer for ASG and related resources
################################################################################

data "aws_acm_certificate" "interview27_certificate" {
  domain   = "interview27-bf-test.com"
  statuses = ["ISSUED"]
}

resource "aws_lb" "test_bf_alb" {
  name               = "${var.web_name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_bf_alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_lb_target_group" "test_bf_tg" {
  name     = "${var.web_name_prefix}-lb-tg"
  vpc_id   = var.vpc_id
  protocol = "HTTP"
  port     = 80

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_security_group" "test_bf_alb_sg" {
  name_prefix = var.web_name_prefix
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address] #My current IP address
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address] #My current IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_alb_listener" "test_bf_alb_listener_http" {
  load_balancer_arn = aws_lb.test_bf_alb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.test_bf_alb.arn
  protocol          = "HTTPS"
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_acm_certificate.interview27_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_bf_tg.arn
  }

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}
