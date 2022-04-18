data "aws_caller_identity" "current" {}

resource "random_string" "random" {
  length           = 4
  special          = false
  upper = false
  number = false
}

resource "aws_alb" "alb" {
  name               = "alloy-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = var.web_subnets
  security_groups = [var.web_sg]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "alloy-load-balancer"
    enabled = true
  }

  tags = {
    Name = "alloy alb"
  }

  depends_on = [aws_s3_bucket.lb_logs]
}

resource "aws_kms_key" "lb_logs_key" {
  description             = "This key is used to encrypt bucket objects"
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "alloy-lb-logs-2022-megashby-${random_string.random.result}"

server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}
}

// note the allowed root account is ELB account in us-east-1
resource "aws_s3_bucket_policy" "allow_alb_to_write_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = data.aws_iam_policy_document.allow_alb_to_write_logs.json
}

data "aws_iam_policy_document" "allow_alb_to_write_logs" {
  statement {
    sid = "1"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::127311923021:root"]
    }
  actions = [
      "s3:*",
  ] 
  resources = [
    aws_s3_bucket.lb_logs.arn,
    "${aws_s3_bucket.lb_logs.arn}/*"
    ] 
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name        = "alloy-alb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  depends_on = [aws_alb.alb]
}

resource "aws_alb_listener" "ecs_api_http_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = 80
  protocol = "HTTP"

 default_action {
   type = "redirect"
   redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
   }
 } 
}

