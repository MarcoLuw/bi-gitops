# Output after provisioning resources
# Outputs are used to extract information from your Terraform configuration after resources are created.

output "tf_instance_ip" {
  value = aws_instance.tf_web.public_ip
}