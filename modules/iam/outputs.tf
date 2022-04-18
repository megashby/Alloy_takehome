output "ec2_instance_profile_name" {
	value = aws_iam_instance_profile.ec2_instance_profile.name
	description = "Name of instance profile to use in EC2 instances"
}