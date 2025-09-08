# SGs for web, app, db, redis, alb


## Security Group: Public ALB Web SG
# Ingress: Allows HTTP/HTTPS from specified CIDRs (internet)
# Egress: Allows all outbound traffic
resource "aws_security_group" "alb_web_sg" {
    name        = "${var.name_prefix}-alb-web-sg"
    description = "Security group for ALB web access"
    vpc_id      = var.vpc_id

    # Allow HTTP and HTTPS from specified CIDR blocks
    dynamic "ingress" {
        for_each = var.alb_web_sg_ingress_cidrs
        content {
            from_port   = var.alb_web_port
            to_port     = var.alb_web_port
            protocol    = "tcp"
            cidr_blocks = [ingress.value]
            description = "Allow HTTP access from ${ingress.value}"
        }
    }

    dynamic "ingress" {
        for_each = var.alb_web_sg_ingress_cidrs
        content {
            from_port   = var.alb_web_ssl_port
            to_port     = var.alb_web_ssl_port
            protocol    = "tcp"
            cidr_blocks = [ingress.value]
            description = "Allow HTTPS access from ${ingress.value}"
        }
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow sg to be deleted when instances are terminated
    lifecycle {
        create_before_destroy = true
    }
}

## Security Group: Private ALB App SG
# Ingress: Allows traffic from web tier target group SG on app port
# Egress: Allows all outbound traffic
resource "aws_security_group" "alb_app_sg" {
    name        = "${var.name_prefix}-alb-app-sg"
    description = "Security group for ALB app access"
    vpc_id      = var.vpc_id

    # Allows traffic from web tier target group SG on app port
    ingress {
        from_port = var.alb_app_port
        to_port = var.alb_app_port
        protocol = "tcp"
        security_groups = [aws_security_group.web_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow sg to be deleted when instances are terminated
    lifecycle {
        create_before_destroy = true
    }
}

## Security Group: Public Web Tier SG
# Ingress: Allows HTTP from ALB web SG
# Egress: Allows all outbound traffic
resource "aws_security_group" "web_sg" {
    name = "${var.name_prefix}-web-sg"
    description = "Security group for web tier access"
    vpc_id = var.vpc_id

    ingress {
        from_port = var.web_port
        to_port = var.web_port
        protocol = "tcp"
        security_groups = [aws_security_group.alb_web_sg.id]
    }

    # SSH enabled?
    dynamic "ingress" {
        for_each = var.enable_ssh ? [1] : []
        content {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            # security_groups = [aws_security_group.bastion_host.id]
        }
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow sg to be deleted when instances are terminated
    lifecycle {
        create_before_destroy = true
    }
}

## Security Group: Private App Tier SG
# Ingress: Allows HTTP from ALB app SG
# Egress: Allows all outbound traffic
resource "aws_security_group" "app_sg" {
    name = "${var.name_prefix}-app-sg"
    description = "Security group for app tier access"
    vpc_id = var.vpc_id

    ingress {
        from_port = var.app_port
        to_port = var.app_port
        protocol = "tcp"
        security_groups = [aws_security_group.alb_app_sg.id]
    }

    # SSH enabled?
    dynamic "ingress" {
        for_each = var.enable_ssh ? [1] : []
        content {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            # security_groups = [aws_security_group.bastion_host.id]
        }
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow sg to be deleted when instances are terminated
    lifecycle {
        create_before_destroy = true
    }
}

## Security Group: Private Redis Tier SG
# Ingress: Allows HTTP from app tier SG
# Egress: Allows all outbound traffic
resource "aws_security_group" "redis_sg" {
    name = "${var.name_prefix}-redis-sg"
    description = "Security group for redis tier access"
    vpc_id = var.vpc_id

    ingress {
        from_port = var.redis_port
        to_port = var.redis_port
        protocol = "tcp"
        security_groups = [aws_security_group.app_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow sg to be deleted when instances are terminated
    lifecycle {
        create_before_destroy = true
    }
}

## Security Group: Private DB Tier SG
# Ingress: Allows HTTP from app tier SG
# Egress: Allows all outbound traffic
resource "aws_security_group" "db_sg" {
    name = "${var.name_prefix}-db-sg"
    description = "Security group for database tier access"
    vpc_id = var.vpc_id

    ingress {
        from_port = var.db_port
        to_port = var.db_port
        protocol = "tcp"
        security_groups = [aws_security_group.app_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow sg to be deleted when instances are terminated
    lifecycle {
        create_before_destroy = true
    }
}