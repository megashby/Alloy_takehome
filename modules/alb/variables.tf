variable "web_sg" {
  type = string
} 

variable "web_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
