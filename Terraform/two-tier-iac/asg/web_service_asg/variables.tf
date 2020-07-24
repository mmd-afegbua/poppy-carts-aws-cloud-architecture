variable "region" {
  description = "Desired region"
  type        = string
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

# variable "subnet_id" {
#  description = "The subnets to associate with the instances"
#  type        = list(string)
#  default     = []
# }

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
#          APP LOAD BALANCER       #
####################################

variable "https_port" {
  description = "The port for HTTPS"
  type = string
  default = 443
}

variable "http_port" {
  description = "The port for HTTP"
  type = string
  default = 80
}

variable "ssl_policy" {
  type        = string
  description = "The name of the SSL Policy for the listener. Required if protocol is HTTPS."
  default     = "ELBSecurityPolicy-2016-08"
}

variable "target_group_port" {
  description = "The port that targets of the lb receives traffic"
  type = string
  default = 80
}

variable "target_group_protocol" {
  description = "The protocol to use for routing traffic to the targets. Should be one of HTTP or HTTPS."
  type        = string
  default     = "HTTP"

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

