variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.0.0.0/16"
}

variable "web_availability_zones" {
  type    = map(number)
  default = {
    "us-east-1c" = 1
    "us-east-1d" = 2
  }
}

variable "app_availability_zones" {
  type    = map(number)
  default =  {
    "us-east-1c" = 3
    "us-east-1d" = 4
  }
}

variable "db_availability_zones" {
  type    = map(number)
  default =  {
    "us-east-1c" = 5
    "us-east-1d" = 6
  }
}