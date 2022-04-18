output "vpc_id" {
  value = aws_vpc.vpc.id
  description = "Id of newly created VPC"
}

output "web_sg_id" {
  value = aws_security_group.web_sg.id
  description = "Id of security group for ALB"
}
 
output "app_sg_id" {
  value = aws_security_group.app_sg.id
  description = "Id of security group for app servers"
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
  description = "Id of security group for db instances"
}

output "web_subnets_id" {
  value = [for subnet in aws_subnet.web_subnet : subnet.id]
  description = "list of subnet ids for web layer"  
}

output "app_subnets_id" {
  value = [for subnet in aws_subnet.app_subnet : subnet.id]
  description = "list of subnet ids for app layer" 

}

output "db_subnets_id" {
  value = [for subnet in aws_subnet.db_subnet : subnet.id]
  description = "list of subnet ids for db layer"
}

