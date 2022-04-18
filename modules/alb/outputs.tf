output "alb_target_group_arn" {
	value = aws_lb_target_group.alb_target_group.arn
	description = "ARN of the target group for the load balancer"
}