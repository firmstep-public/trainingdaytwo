variable "availability_zones" {
  description = "description"
  type        = "list"
}

variable "region" {
  description = "description"
}

variable "vpc_id" {
  description = "description"
}

variable "subnet_ids" {
  description = "description"
  type        = "list"
  default     = []
}

variable "ami_id" {
  description = ""
}

variable "tags" {
  description = ""
  type        = "map"
  default     = {}
}

variable "name" {
  description = ""
}

variable "user_data" {
  description = ""
  default     = "#"
}

variable "instance_type" {
  description = ""
  default     = "t2.micro"
}
