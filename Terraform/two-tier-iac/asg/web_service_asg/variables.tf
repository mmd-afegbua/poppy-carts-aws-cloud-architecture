variable "region" {
  description = "Desired region"
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

#variable "user_data" {
#  description = "Script to run on starting"
#  type        = string
#  default     = null
#}

variable "subnet_id" {
  description = "The subnets to associate with the instances"
  type        = list(string)
  default     = []
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

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool
}

####################################
#         LOAD BALANCER            #
####################################

variable "elb_name" {
  description = "Name of ELB for each ASG"
  type = string
}

variable "elb_port" {
  description = "Ingress port for the ALB"
  type = string
}


####################################
#        OPTIONAL PARAMETERS       #
####################################

variable "target_group_arns" {
  description = "The ARNs of ELB target groups in which to register Instances"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type        = string
  default     = "EC2"
}


variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}