###########Desired Infra#############
# Two-Tier, security hardened auto  #
# scaling group with no SSH access. #
# Refer to the diagram for reference#
#####################################

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "poppy-carts-terraform-backend"
    key    = "two-tier-iac/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_launch_configuration" "poppy_carts_config" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data       = file("start_up.sh")

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "poppy_carts_asg" {
  # Explicitly depend on the launch configuration's name so each time 
  # it's replaced, this ASG is also replaced
  name = "${var.asg_name}-${aws_launch_configuration.poppy_carts_config.name}"

  launch_configuration = aws_launch_configuration.poppy_carts_config.name

  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.public_subnets

  # Configure integrations with a load balancer
  target_group_arns = [aws_lb_target_group.poppy_carts_tg.arn]
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  # Wait for at least this many instances to pass health checks before
  # considering the ASG deployment complete
  
  # min_elb_capacity = var.min_size #crossed for troubleshooting

  # When replacing this ASG, create the replacement first, and only delete the
  # original after
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = {
      for key, value in var.custom_tags :
      key => upper(value)
      if key != "Name"
    }

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}

###########################
# Auto-scaling scheduling #
###########################

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.asg_name}-scale-out-during-business-hours"
  min_size               = 1
  max_size               = 10
  desired_capacity       = 4
  recurrence             = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.poppy_carts_asg.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name  = "${var.asg_name}-scale-in-at-night"
  min_size               = 1
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = aws_autoscaling_group.poppy_carts_asg.name
}

####################################
# Security Group for each instance #
####################################

resource "aws_security_group" "instance" {
  name   = "${var.asg_name}-instance"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    # or "all"
    cidr_blocks = local.all_ips
  }
}


################
# Alarm Metric #
################

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.asg_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.poppy_carts_asg.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name  = "${var.asg_name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.poppy_carts_asg.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}

locals {
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}