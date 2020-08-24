###################################
# ELB - Application Load Balancer #
###################################

resource "aws_elb" "internal_elb" {
  name               = var.elb_name
  security_groups    = [aws_security_group.elb_sg.id]
  availability_zones = var.availability_zones
  subnets            = data.terraform_remote_state.vpc.outputs.private_subnets

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}


resource "aws_security_group" "elb_sg" {
  name   = "poppy-carts-external-elb"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

# Allow specific outbound traffic - tweak the ports
resource "aws_security_group_rule" "ingress" {
  type = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  # The CIDR range can also be tweaked for security hardening
  cidr_blocks = ["0.0.0.0/0"]
}

# Inbound HTTP from web app only
resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port   = var.elb_port
  to_port     = var.elb_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_alb_target_group" "poppy_carts_tg" {
  name     = "poppy-carts-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/login"
    port = 80
  }
}