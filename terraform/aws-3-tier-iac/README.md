# AWS 3-Tier Infrastructure as Code

This Terraform project implements a 3-tier architecture on AWS with multi-region deployment capabilities.

## Structure

- `globals/` - Common variables and tags
- `modules/` - Reusable Terraform modules
- `envs/` - Environment-specific configurations
- `policy/` - IAM policies and SCPs

## Usage

Configure your environment in the appropriate `envs/` directory and run Terraform commands from there.
