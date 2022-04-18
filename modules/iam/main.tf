data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2_iam_role" {
  name = "EC2-Role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}

resource aws_iam_instance_profile "ec2_instance_profile" {
  name = "EC2-Profile"
  role = aws_iam_role.ec2_iam_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_iam_role_policy_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


resource "aws_iam_policy" "sm_read_access" {
  name = "sm-read-access"
  path = "/"
  description = "sm-read-access"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            Resource: [
                "${var.db_secret_arn}"
            ]
        },
        {
            Effect: "Allow",
            Action: "secretsmanager:ListSecrets",
            Resource: "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_iam_role_policy_attachment_sm" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.sm_read_access.arn
}

