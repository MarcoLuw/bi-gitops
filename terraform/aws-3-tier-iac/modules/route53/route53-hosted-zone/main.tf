# Route53 Hosted Zone Module

resource "aws_route53_zone" "this" {
    name          = var.zone_name
    comment       = var.comment
    force_destroy = var.force_destroy
    tags          = var.tags
    dynamic "vpc" {
        for_each = var.vpc_ids
        content {
            vpc_id = vpc.value
        }
    }
}

# Optional: create alias record pointing to an internal ALB
resource "aws_route53_record" "alias" {
  # count   = var.create_alias_record && var.record_name != null && var.alias_target_dns != null && var.alias_target_zone_id != null ? 1 : 0
  count   = var.create_alias_record ? 1 : 0 # above will fail since alias_target_dns and alias_target_zone_id are not known until apply, so plan will error
  zone_id = aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.alias_target_dns
    zone_id                = var.alias_target_zone_id
    evaluate_target_health = true
  }
}