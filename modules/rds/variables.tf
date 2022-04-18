variable "rds_storage" {
  type = number
  default   = "10"
}

variable "db_subnets_id" {
	type = list(string)
}

variable "db_sg_id" {
	type = string
}
