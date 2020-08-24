# poppy-carts-aws-cloud-architecture
## Root Repo
### Folder Arrangement
- schematics: Schematics that I had time to upload. Updates are continually being made and the infra might change. Don't take thems serious.
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

### Getting it to work
#### 1. Decide whether to use a local backend or a remote backend
If you are going to be using a local back end, skip this step. Else...
Navigate to poppy-carts-aws-cloud-architecture/Terraform/global/backend, open the backend.tf file and comment (#) all lines. Apparently, the code is directing terraform to use an s3 bucket and a dynamoDB that you have not created. You have to create it first, then remove the comment. To do this,
```
terraform init
terraform apply
```
Remove the comment from the backend.tf

```
terraform init
terraform apply
```

#### 2. VPC or IAM Roles?
Root account is not a good security practise. But then let's skip the IAM and go to VPC