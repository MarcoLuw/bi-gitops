# Route53 Record module main.tf

# Record resource creation
resource "aws_route53_record" "this" {
    zone_id = var.zone_id
    name = var.record_name
    type = var.record_type

    # If alias is not set, use TTL
    # TTL is ignored if alias is set
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
    ttl = var.alias_name == null ? var.ttl : null
    records = var.alias_name == null ? var.records : null

    alias {
        name                   = var.alias_name
        zone_id                = var.alias_zone_id
        evaluate_target_health = var.evaluate_target_health
    }
}