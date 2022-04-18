resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "web sg"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "app sg"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "db sg"
  vpc_id      = aws_vpc.vpc.id
}


resource "aws_security_group_rule" "web_sg_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_sg_ingress_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_sg_ingress_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "app_sg_ingress_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
 
  security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "app_sg_ingress_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
 
  security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "app_sg_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 
  security_group_id = aws_security_group.app_sg.id
}


resource "aws_security_group_rule" "db_sg_in_rds" {
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  
  security_group_id = aws_security_group.db_sg.id
}
  

resource "aws_security_group_rule" "db_sg_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 
  security_group_id = aws_security_group.db_sg.id
}


