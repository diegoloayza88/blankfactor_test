################################################################################
# Launch Template
################################################################################

resource "aws_launch_template" "test_bf_launch_template" {
  name                   = "${var.web_name_prefix}-nginx-launch-template"
  instance_type          = var.instance_type
  update_default_version = true
  image_id               = var.image_id

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.test_bf_asg_sg.id]
    subnet_id                   = var.subnet_ids[0]
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

  user_data = filebase64("modules/web/files/user_data.sh")

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

################################################################################
# IAM role and policy for instance profile
################################################################################
resource "aws_iam_role" "test_bf_instance_profile_role" {
  assume_role_policy = file("modules/web/files/role_trust_policy.json")
  name               = "${var.web_name_prefix}-instance-profile-role"

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
  policy = file("modules/web/files/instance_policy.json")
  name   = "${var.web_name_prefix}-instance-profile-policy"

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
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 300
  max_size                  = 3
  min_size                  = 1
  termination_policies      = ["OldestInstance", "Default"]
}

resource "aws_autoscaling_policy" "test_bf_asg_policy" {
  autoscaling_group_name    = aws_autoscaling_group.test_bf_asg.name
  name                      = "${var.web_name_prefix}-asg-policy"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 60

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.target_value
  }
}

################################################################################
# Application load balancer for ASG and related resources
################################################################################

resource "aws_lb" "test_bf_alb" {
  name               = "${var.web_name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_bf_alb_sg.id]
  subnets            = var.subnet_ids

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}

resource "aws_lb_target_group" "test_bf_tg" {
  name        = "${var.web_name_prefix}-lb-tg"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = 80

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  # To avoid the creation of a certificate to enable HTTPS because of time and
  # testing purposes, this is just for visibility of best practices
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_alb_listener" "test_bf_alb_listener" {
  load_balancer_arn = aws_lb.test_bf_alb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_bf_tg.arn
  }

  tags = merge(
    { "Name" = "${upper(var.web_name_prefix)}-${upper(var.region)}" },
    var.tags
  )
}