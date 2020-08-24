# poppy-carts-aws-cloud-architecture
## Root Repo
### Folder Arrangement
- schematics:
- terraform
  - global
    - backend: Required to implemet remote backend and locks. Creates s3 bucket and dynamoDB for backend.
    - iam_roles: Required for granular iam access controls for different departments.
  - modules
    - vpc: Creates the isolated VPC for the entire infrastructure. Two private subnets and two public subnets that can be adjusted, NAT gateway and the likes.
    - lambda: Files needed for all lambda resources to be provisioned.
    - compute_instances
      - web_app_asg: The backend instances with autoscaling groups, health checks, security groups and internal loadbalancer.
      - web_service_asg: The frontend instances with autoscaling groups, health checks, security groups and external load balancer (ALB).