# Parameterized ALB (public or internal), listeners, TGs

# ALB resource
resource "aws_lb" "this" {
    name               = "${var.name}-alb"
    internal          = var.internal
    load_balancer_type = "application"
    security_groups   = var.security_group_ids
    subnets           = var.subnet_ids

    enable_deletion_protection = false

    tags = {
        Name = "${var.name}-alb"
    }
}

data "aws_subnet" "first" {
    id = try(var.subnet_ids[0], "")
}

# Target Group
resource "aws_lb_target_group" "this" {
    name     = "${var.name}-tg"
    port     = var.target_group_port
    protocol = "HTTP"
    vpc_id   = data.aws_subnet.first.vpc_id != "" ? data.aws_subnet.first.vpc_id : var.vpc_id # get VPC ID from first subnet ID

    target_type = var.target_type

    health_check {
        path                = var.health_check.path
        matcher             = var.health_check.matcher
        interval           = var.health_check.interval
        healthy_threshold   = var.health_check.healthy_threshold
        unhealthy_threshold = var.health_check.unhealthy_threshold
        timeout            = var.health_check.timeout
    }

    tags = {
        Name = "${var.name}-tg"
    }
}

# HTTP Listener on port 80
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.this.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.this.arn
    }
}

# Optional HTTPS Listener on port 443 with ACM certificate
resource "aws_lb_listener" "https" {
    count = var.listener_https && var.certificate_arn != "" && var.certificate_arn != null ? 1 : 0

    load_balancer_arn = aws_lb.this.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = var.certificate_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.this.arn
    }
}