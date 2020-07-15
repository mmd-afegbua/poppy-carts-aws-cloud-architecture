variable "name" {
    description = "Name tag for all resources"
    type        = string
}

variable "aws_access_key" {
    type            = string
    default         = ""
}

variable "aws_secret_key" {
    type            = string
    default         = ""
}

variable "ami" {
    description = "Amazon machine image id"
    type        = string
}

variable "instance_type" {
    description = "The instance type"
    type        = string
}

variable "key_name" {
    description = "Key pair name"
    type        = string
    default     = ""
}

variable "security_group_ids" {
    description = "A list of the firewall rules to link with the instance"
    type        = string
    default     = null
}

variable "subnet_id" {
    description = "The subnets to associate with the instances"
    type        = list(string)
    default     = []
}

