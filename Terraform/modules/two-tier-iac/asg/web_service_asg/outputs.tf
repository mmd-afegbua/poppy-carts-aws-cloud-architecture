output "launch_configuration" {
    value = aws_launch_configuration.poppy_carts_config.name
}

output "external_lb_arn" {
    value = aws_lb.external_lb.arn
}

output "external_lb_dns" {
    value = aws_lb.external_lb.dns_name
}