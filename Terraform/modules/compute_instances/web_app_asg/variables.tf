variable "region" {
    description = "Region to be used. It should be same with the web service infra"
    type = string
}

variable "asg_name" {
  description = "Name tag for all resources"
  type        = string
}

variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

variable "key_name" {
  description = "Key pair name"
  type        = string
  default     = ""
}

variable "ami" {
  description = "Amazon machine image id"
  type        = string
}

variable "instance_type" {
  description = "The instance type"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
}

variable "security_group_ids" {
  description = "A list of the firewall rules to link with the instance"
  type        = string
  default     = null
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type        = string
  default     = "EC2"
}