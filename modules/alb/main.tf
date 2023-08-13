
locals {
  module_path                = "${replace(path.module, "\\", "/")}"
  workstation-external-cidr  = "${chomp(data.http.workstation-external-ip.response_body)}/32"
  consul_datacenter          = "opsschool"
  consul_listener            = "consul.dianatop.lat"
  jenkins_listener           = "jenkins.dianatop.lat"
  kibana_listener            = "kibana.dianatop.lat"
  grafana_record             = "grafana.dianatop.lat"
  prometheus_record          = "prometheus.dianatop.lat"
  kandula_record             = "kandula.dianatop.lat"
  openvpn_record             = "openvpn.dianatop.lat"
  private_zone_domain        = "dianatop.lat."
}


#Retrieve my public ip address
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}


# create a security group for the application load balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb security group"
  description = "enable access on various ports"
  vpc_id      = var.vpc_id
  
  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = [var.anyware_cidr_range]
  }

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = [var.anyware_cidr_range]
  }
  
  ingress {
    description      = "Jenkins UI access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "TCP"
    cidr_blocks      = [local.workstation-external-cidr]
  }

  ingress {
    description      = "Allow consul UI access"
    from_port        = 8500
    to_port          = 8500
    protocol         = "tcp"
    cidr_blocks      = [local.workstation-external-cidr]   
  }

  ingress {
    description      = "Allow prometheus UI access"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = [local.workstation-external-cidr]  
  }

  ingress {
    description        = "Allow Kibana UI"
    from_port          = 5601
    to_port            = 5601
    protocol           = "TCP"
    cidr_blocks        = [local.workstation-external-cidr]
  }

  ingress {
    description      = "Allow grafana UI access"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = [local.workstation-external-cidr]   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.anyware_cidr_range]
  }

  tags   = {
    Name = "opschool-project-alb-sg"
  }
}



# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name                       = "opschool-project-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [var.public_subnet_id[0], var.public_subnet_id[1]]
  enable_deletion_protection = false

  tags   = {
    Name = "opschool-project-alb"
  }
}


# create a listener on port 80 with redirecting action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn   = aws_lb.application_load_balancer.arn
  port                = 80
  protocol            = "HTTP"

  default_action {
    type              = "redirect"
    redirect {
      protocol      = "HTTPS"
      port          = "443"
      status_code   = "HTTP_301"
    }
  }
}


# Create a listener on port 443 with forwarding action
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.cert_arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.jenkins_target_group.arn
        weight = 1
      }

      target_group {
        arn    = aws_lb_target_group.consul_target_group.arn
        weight = 1
      }

      target_group {
        arn    = aws_lb_target_group.logging_target_group.arn
        weight = 1
      }

      stickiness {
        enabled  = true
        duration = 60
      }
    }
  }
}


#Rule for consul
resource "aws_lb_listener_rule" "consul" {
  listener_arn = aws_lb_listener.alb_https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_target_group.arn
  }

  condition {
    host_header {
      values = ["local.consul_listener"]
    }
  }
}


#Rule for jenkins
resource "aws_lb_listener_rule" "jenkins" {
  listener_arn = aws_lb_listener.alb_https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  }

  condition {
    host_header {
      values = ["local.jenkins_listener"]
    }
  }
}


#Rule for logging
resource "aws_lb_listener_rule" "logging" {
  listener_arn = aws_lb_listener.alb_https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.logging_target_group.arn
  }

  condition {
    host_header {
      values = ["local.kibana_listener"]
    }
  }
}



#Jenkins:
# create target group
resource "aws_lb_target_group" "jenkins_target_group" {
  name        = "opschool-project-jenkins-tg"
  target_type = "instance"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/login"
    protocol            = "HTTP"   
    interval            = 30
    timeout             = 6
    matcher             = "200-299"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type              = "lb_cookie"
    cookie_duration   = 60
  }

  lifecycle {
    create_before_destroy = true
  }
  
  tags   = {
    Name = "opschool-project-jenkins-tg"
 }
}


#Attach the target group to an instance
resource "aws_lb_target_group_attachment" "attach_jenkins_server_instances" {
  count            = var.jenkins_server_instances_count
  target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  target_id        = var.jenkins_server_instance_id[count.index]
  port             = 8080
}


#Consul:
# create target group
resource "aws_lb_target_group" "consul_target_group" {
  name                  = "opschool-project-consul-tg"
  target_type           = "instance"
  port                  = 8500
  protocol              = "HTTP"
  vpc_id                = var.vpc_id

  health_check {
    enabled             = true
    path                = "/ui/${local.consul_datacenter}"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type              = "lb_cookie"
    cookie_duration   = 60
  }

  lifecycle {
    create_before_destroy = true
  }
  
  tags   = {
    Name = "opschool-project-consul-tg"
 }
}


#Attach the target group to an instance
resource "aws_lb_target_group_attachment" "attach_consul_instances" {
  count            = var.consul_instances_count
  target_group_arn = aws_lb_target_group.consul_target_group.arn
  target_id        = var.consul_server_instance_id[count.index]
  port             = 8500
}



#logging:
# create target group
resource "aws_lb_target_group" "logging_target_group" {
  name        = "opschool-project-logging-tg"
  target_type = "instance"
  port        = 5601
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/app/home"
    protocol            = "HTTP"   
    interval            = 30
    timeout             = 6
    matcher             = "200,302"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type              = "lb_cookie"
    cookie_duration   = 60
  }

  lifecycle {
    create_before_destroy = true
  }
  
  tags   = {
    Name = "opschool-project-logging-tg"
 }
}


#Attach the target group to an instance
resource "aws_lb_target_group_attachment" "attach_logging_instances" {
  count            = var.logging_instances_count
  target_group_arn = aws_lb_target_group.logging_target_group.arn
  target_id        = var.logging_instance_id[count.index]
  port             = 5601
}


###########################

# Retrieve existing Route 53 zone
#data "aws_route53_zone" "hosted_zone" {
#  name         = local.private_zone_domain
#  private_zone = true
#  vpc_id       = var.vpc_id
#}


resource "aws_route53_zone" "private_zone" {
  name = local.private_zone_domain

  vpc {
    vpc_id     = var.vpc_id
    vpc_region = var.aws_region
  }
}

# Update Route 53 records for the subdomains
resource "aws_route53_record" "consul_record" {
  zone_id   = aws_route53_zone.private_zone.zone_id
  name      = local.consul_listener
  type      = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "jenkins_record" {
  zone_id   = aws_route53_zone.private_zone.zone_id
  name      = local.jenkins_listener
  type      = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "kibana_record" {
  zone_id   = aws_route53_zone.private_zone.zone_id
  name      = local.kibana_listener
  type      = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "grafana_record" {
  zone_id   = aws_route53_zone.private_zone.zone_id
  name      = local.grafana_record
  type      = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "prometheus_record" {
  zone_id   = aws_route53_zone.private_zone.zone_id
  name      = local.prometheus_record
  type      = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "kandula_record" {
  zone_id   = aws_route53_zone.private_zone.zone_id
  name      = local.kandula_record
  type      = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "openvpn_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = local.openvpn_record
  type    = "A"

  records = [var.eip_openvpn]
  ttl     = 300
}
