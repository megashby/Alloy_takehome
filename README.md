
# Pre-requisites for deploying this TF code:

1. Have a machine with terraform already installed (see instructions here: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started )
2. Have an AWS user with programmatic access with sufficient permissions to create, read, update, and delete AWS resources. 
3. Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY as environment variables for the above user as such credentials are not included in this demo
4. Set AWS_DEFAULT_REGION as "us-east-1" via environment variables.

# Overall architecture
This will create a 3 tier architecture with web, app and db tiers. The web tier is exposed to the internet and contains an ALB. The web tier contains an autoscaling group of ec2 instances that allow access from the ALB but do not have public IP addresses themselves. The db tier contains an RDS instance and allows port 3306 connections from the app tier where our application will eventually run. 

# How this repo is organized

## networking
This module contains the terraform code to set up the VPC, subnets, security groups, internet gateways, and route tables for a 3-tiered architecture (web, app, db layers) in 2 availability zones (us-easet-1c and us-east-1d for the sake of not using more popular 1a and 1b) in the us-east-1 region. The us-east-1 region was chosen due to proximity of Alloy's existing customer base and wide suport of AWS services and features. 

**gateways.tf** creates the public IGW and NAT GW in the public subnet and the route tables. The NAT GW is only created in the us-east-1c AZ for cost and demonstration purposes, but should be made more HA in production environments. Both are launched in the web (public) subnet. This file also creates three route tables (web, app, and db) and associates the corresponding subnets to those route tbales. The web route table routes traffic through the IGW, and the app and db route tables route traffic through the NAT GW.

**sg.tf** makes three security groups, one for each tier of our architecture -  web, app, and db. In the web security group, because we want our application accessible to the internet, we will have opened ports 80 and 443 from 0.0.0.0/0. This is the security group where our load balancer will sit. In the app security group we have also opened up ports 0 and 443, but we are only ingress allowing traffic from the web sewcurity group, so traffic goes through the load balancer and does not hit our EC2 instances directly. Similarily in the db security group, we are only allowing port 3306 (MySQL) from the app security group so our EC2 instances can communicate with RDS.

**main.tf** makes the new VPC and the subnets for the three tiers in 2 AZs each. We do not want to use the default VPC or else our instances will automatically be assigned public and private IP addresses and subnets would have a route out to the internet. In the web subnet, we are automatically assigning public IP addresses so the load balancer is publicly accessible, however in the app and db subnets we are not as the traffic should only come internally. For best practice we are also enabling VPC flow logs on all traffic types (to see both accepted and rejected traffic) and a new CW logs group for our newly created VPC and encrypting these with KMS. For the KMS key policy we are delegating access to IAM permissions and additioanlly allowing CW logs to have access to the key. We are also making a new role for VPC flow logs to assume that can create the log stream and put logs. 

## rds
**main.tf** makes a multi-AZ RDS Instance in a subnet group made up of our db subnets and in the db security group. For demonstrations sake we have kept the storage quite low. To store the credentials to this database we have terraform generate a random password and store this along with the database username in secrets manager and encrypted with the default encryption key. Because we are not doing any cross-account access, I have not defined a resoure policy for this secret. Additionally, I am not setting a value for recovery_window_in_days because the default is 30 days.

## iam
**main.tf** creates an IAM role the EC2 instances will use as their instnace profile. This role has 2 policies attached, 1 is the AWS managed CloudWatchAgentServerPolicy (https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/CloudWatchAgentServerPolicy) to write logs to cloudwatch logs and create log stream. Since we have stored our RDS credentials in secrets manager that the EC2 instances will need to access the db, I have created an additional policy that gives the role access to list all secrets and retrieve the value of the database creds secret.

## alb
**main.tf** creates the ALB in the wen subnet and security group so it is accessible from the internet. This ALB has access logs enabled and stored in a separate, encrypted s3 bucket. Permissions are defined via the bucket policy to allow the ELB logging account access to write logs into the s3 bucket. We are constrained in what kind of key we can use to encrypt this bucket as it needs to be accessible by the ELB account. Therefore, we will use the s3 service key instead to encrypt htis bucket. The alb  forwards traffic to the an autoscaling group of EC2 instances defined in *asg* module.

## asg
**main.tf** Creates the Amazon linux AMI for this autoscaling group in size t2.micro for costs sake using the AWS linux AMI. These instances are part of a launch configuration which will deploy into the app security group with the IAM instance role created in *iam*. These instances will be launched into our app security group which allows access from the load balancer. For the auto scaling group, I set the minimum number of instances as 2 and the max as 5. The number of EC2 instances will scale up by 1 when the average CPU utilization is greater than or equal to 80% for 2 evaluation periods of 2 minutes each. I chose these parameters to prevent constant adding and removing of instances due to small instance size. For the same reason, the cooldown period is set to 2 minutes. The number of instances will scale down by 1 if the average CPU utilization is less than or equal to 10% for the same 2 evalution periods of 2 mins each. 

