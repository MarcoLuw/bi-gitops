# Launch template, ASG, instance profile, SSM, userdata

# Get user data
locals {
    user_data_rendered = var.user_data_base64 != "" ? var.user_data_base64 : (
        var.user_data_template != "" ? base64encode(templatefile("${path.module}/templates/${var.user_data_template}", var.user_data_vars)) : ""
    )
}

# Launch Template
resource "aws_launch_template" "this" {
    name_prefix   = "${var.name}-lt-"
    image_id      = var.ami_id
    instance_type = var.instance_type
    
    vpc_security_group_ids = var.security_group_ids
    
    iam_instance_profile {
        name = var.iam_instance_profile
    }

    user_data     = local.user_data_rendered
    monitoring {
        enabled = var.enable_detailed_monitoring
    }

    lifecycle {
        create_before_destroy = true
    }

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "${var.name}-ec2"
            Module = "asg-ec2"
            Terraform = "true"
        }
    }

    tag_specifications {
        resource_type = "volume"
        tags = {
            Name = "${var.name}-ec2-volume"
        }
    }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
    name                      = "${var.name}-asg"
    max_size                  = var.max_size
    min_size                  = var.min_size
    desired_capacity          = var.desired_capacity
    vpc_zone_identifier       = var.subnet_ids
    
    launch_template {
        id      = aws_launch_template.this.id
        version = aws_launch_template.this.latest_version #"$Latest"
    }

    target_group_arns         = var.target_group_arns
    health_check_type         = length(var.target_group_arns) > 0 ? "ELB" : "EC2"
    health_check_grace_period = 300
    force_delete              = true
    wait_for_capacity_timeout = "10m"
    
    tag {
        key                 = "Name"
        value               = "${var.name}-ec2"
        propagate_at_launch = true
    }

    instance_refresh {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage = 0   # replace all instances at once
        instance_warmup        = 50
        skip_matching          = false
      }
      triggers = ["launch_template"]
    }

    lifecycle {
        create_before_destroy = true
    }
}

# Scaling Policy: optional, baseline
resource "aws_autoscaling_policy" "scale_out" {
    name                  = "${var.name}-scale-out"
    autoscaling_group_name = aws_autoscaling_group.this.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = 1
    cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in" {
    name                  = "${var.name}-scale-in"
    autoscaling_group_name = aws_autoscaling_group.this.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = -1
    cooldown               = 300
}