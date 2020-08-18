data "terraform_remote_state" "vpc" {
    backend = "s3"

    config = {
        bucket = "poppy-carts-terraform-backend"
        key = "two-tier-iac/vpc/terraform.tfstate"
        region = "us-east-1"
    }
}

resource "aws_security_group" "backend_instance" {
    name = "${var.asg_name}-backend_instance"
#    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_security_group_rule" "ingress_https" {
    type = "ingress"
    from_port = local.from_port
    to_port = local.to_port
    protocol = local.protocol
    cidr_blocks = local.cidr_blocks
    security_group_id = aws_security_group.backend_instance.id
}

resource "aws_security_group_rule" "egress" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = local.cidr_blocks
    security_group_id = aws_security_group.backend_instance.id
}

locals {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
}
resource "aws_launch_configuration" "poppy_carts_backend" {
    image_id = var.ami
    instance_type = var.instance_type
    security_groups = [aws_security_group.backend_instance.id]
#    user_data = ""

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "poppy_carts_backend" {
    name = "${var.asg_name}-poppy_carts_backend"
    launch_configuration = aws_launch_configuration.poppy_carts_backend.name
#    vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnets
    target_group_arns = []
    health_check_type = var.health_check_type

    min_size = var.min_size
    max_size = var.max_size

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
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.asg_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.poppy_carts_backend.name
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
    AutoScalingGroupName = aws_autoscaling_group.poppy_carts_backend.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}

