# AWS 3-Tier Infrastructure as Code

This Terraform project implements a 3-tier architecture on AWS with multi-region deployment capabilities.

## Pattern
per-environment/per-region stacks -> clean state isolation, clear blast radius, and explicit provider aliasing

## Structure
- `globals/` - Common variables and tags
- `modules/` - Reusable Terraform modules
- `envs/` - Environment-specific configurations
- `policy/` - IAM policies and SCPs

## Usage
Configure your environment in the appropriate `envs/` directory and run Terraform commands from there.

## Best Practices
### 1. **State File:** Isolation and locking
- Separate state files per env/region using `backend.tf` in each stack
    - S3 backend to store state files
    - DynamoDB for state locking and consistency
- Prevent concurrent modifications with state locking and limit blast radius

### 2. **Provider:** Explicit Provider Aliasing
- Aliased providers (aws.primary, aws.secondary), helping to avoid confusion and mistakes when working with multiple regions
- Version pinning for provider stability
- Predictable, consistent deployments and safe upgrades

### 3. **Modularization:** Reusable Module Interfaces
- Modular design for **reusability** and **maintainability**: networking, alb,... modules
- Follow **single responsibility principle** for Terraform modules
- Clear separation of concerns, reduce drift, duplication, and enforce consistnet patterns

### 4. **Code Structure:** Environment-Specific Configurations
```txt
├─ envs/
│  ├─ dev/
│  │  ├─ region-primary/          # ap-southeast-2
│  │  │  ├─ backend.tf
│  │  │  ├─ main.tf               # calls modules/* once (primary region)
│  │  │  ├─ providers.tf          # aliased "primary"
│  │  │  ├─ variables.tf
│  │  │  └─ terraform.tfvars
│  │  └─ region-secondary/        # ap-northeast-2
│  ├─ staging/
│  │  ├─ region-primary/
│  │  └─ region-secondary/
│  └─ prod/
│     ├─ region-primary/
│     └─ region-secondary/
```
- Tailored configurations for different environments and regions
- Clear lifecycle management and access boundaries

### 5. **Global Convetion** Naming and Tagging
- Naming conventions and tagging strategies for resource identification and **cost allocation**