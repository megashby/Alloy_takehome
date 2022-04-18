data "aws_caller_identity" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
    tags = {
      Name = "alloy vpc"
  }
}

#create 1 web subnet in each of the 2 AZs

resource "aws_subnet" "web_subnet" {
  for_each = var.web_availability_zones
 
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
 
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  map_public_ip_on_launch = true

  tags = {
    Name = "alloy web subnet"
  }
 }

#create 1 app subnet in each of the 2 AZs

resource "aws_subnet" "app_subnet" {
  for_each = var.app_availability_zones
 
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
 
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4 , each.value)

  map_public_ip_on_launch = true

  tags = {
    Name = "alloy app subnet"
  }
 }

#create 1 db subnet in each of the 2 AZs

resource "aws_subnet" "db_subnet" {
  for_each = var.db_availability_zones

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4 , each.value)

  map_public_ip_on_launch = false

  tags = {
    Name = "alloy db subnet"
  }
}

#vpc flow logs

resource "aws_kms_key" "cloudwatch_kms_key" {
  description             = "Used to encrypt cloudwatch log group"
  enable_key_rotation     = true
  tags = {
    Name = "alloy kms cw logs key"
  }

  policy =  <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
          {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
    {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.us-east-1.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*"

        }    
 ]
}
EOT

}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_cw_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_cw_log_group" {
  name = "VPC-flow-logs"
  kms_key_id = aws_kms_key.cloudwatch_kms_key.arn
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "VPC-flow-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_logs_CW_policy" {
  name = "VPC-flow-logs-cw-logs-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}