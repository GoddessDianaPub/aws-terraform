output "alb_sg" {
   value = aws_security_group.alb_sg.id
}

output "application_load_balancer_arn" {
   value = aws_lb.application_load_balancer.arn
}

output "alb_dns_name" {
   value = aws_lb.application_load_balancer.dns_name
}

output "alb_jenkins_target_group_arn" {
   value = aws_lb_target_group.jenkins_target_group.arn
}

output "alb_consul_target_group_arn" {
   value = aws_lb_target_group.consul_target_group.arn
}

output "alb_logging_target_group_arn" {
   value = aws_lb_target_group.logging_target_group.arn
}
