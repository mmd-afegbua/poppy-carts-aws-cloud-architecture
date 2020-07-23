######################################
# Application Load Balancer - HTTP/S #
######################################

resource "aws_lb" "external_lb" {
    load_balancer_type = "application"
    name = "poppy-carts-alb"
    internal = false
    subnets = data.terraform_remote_state.vpc.outputs.public_subnets   
}

# HTTPS first
resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.arn
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

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.arn
    port = var.http_port
    protocol = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            port = var.https_port
            protocol = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

resource "aws_lb_target_group" "poppy-carts-tg" {
    name = "poppy-carts-tg"
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    port = var.target_group_port
    protocol = var.target_group_protocol

    target_type = "ip"
    
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

