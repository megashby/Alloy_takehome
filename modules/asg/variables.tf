variable "ec2_instance_profile_name" {
  type = string
}

variable "app_sg" {
  type = string
} 

variable "app_subnets" {
  type = list(string)
}

variable "alb_target_group_arn" {
	type = string
}