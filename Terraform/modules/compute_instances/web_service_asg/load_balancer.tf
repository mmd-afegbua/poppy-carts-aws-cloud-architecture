######################################
# Application Load Balancer - HTTP/S #
######################################

resource "aws_lb" "external_lb" {
    load_balancer_type = "application"
    name = "poppy-carts-alb"
    internal = false
    security_groups = [aws_security_group.poppy_carts_exlb_sg.id]
    subnets = data.terraform_remote_state.vpc.outputs.public_subnets

    /*
    access_logs {
      bucket =
      prefix =
      enable = true
    } */   
}

/*
# HTTPS first
resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.external_lb.arn
    port = var.https_port
    protocol = "HTTPS"
    ssl_policy = var.ssl_policy
    certificate_arn = ""

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404 not found"
            status_code = "404"
        }
    }
}
*/

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.external_lb.arn
    port = var.http_port
    protocol = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            port = var.https_port
            protocol = "HTTP"
            status_code = "HTTP_301"
        }
    }
}

resource "aws_lb_target_group" "poppy_carts_tg" {
    name = "poppy-carts-tg"
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    port = var.target_group_port
    protocol = var.target_group_protocol

    target_type = "instance"
    
    health_check {
        path = "/"
        healthy_threshold = 4
        unhealthy_threshold = 2
        timeout = 5
        port = "traffic-port"
        protocol= "HTTP"
    }
    depends_on = [aws_lb.external_lb]
}

/*
resource "aws_lb_listener_rule" "https" {

  listener_arn = aws_lb_listener.https.arn
  priority     = 50000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.poppy_carts_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  # Changing the priority causes forces new resource, then network outage may occur.
  # So, specify resources are created before destroyed.
  lifecycle {
    create_before_destroy = true
  }
}
*/

resource "aws_lb_listener_rule" "http" {

  listener_arn = aws_lb_listener.http.arn
  priority     = 50000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.poppy_carts_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "poppy_carts_exlb_sg" {
  name = "poppy_carts_exlb_sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

#  tags = merge({"Name" = aws_security_group.poppy_carts_exlb_sg.name}, 1)
}

# HTTP SG for testing, to be replaced by HTTPS in integration tests.
resource "aws_security_group_rule" "ingres_http" {
  
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.poppy_carts_exlb_sg.id
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.poppy_carts_exlb_sg.id
}

/*
resource "aws_security_group_rule" "ingres_https" {
  
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.poppy_carts_exlb_sg.id
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.poppy_carts_exlb_sg.id
}
*/
