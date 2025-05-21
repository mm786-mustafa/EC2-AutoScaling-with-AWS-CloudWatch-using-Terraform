data "aws_region" "current" {} # Fetching Current Region

# *** Application Load Balancer ***
resource "aws_alb" "my_alb" {
  load_balancer_type = "application"
  name = "${var.lb_name}-${var.environment}"
  internal = false
  ip_address_type = "ipv4"
  security_groups = [ var.security_group_id ]
  subnets = var.public_subnet_ids
  tags = {
    Name = "${var.environment}-${var.lb_name}-${data.aws_region.current.name}"
  }
}

# *** ALB Listener ***
resource "aws_alb_listener" "my_alb_listener" {
  default_action {
    type = "forward"
    target_group_arn = var.target_group_arn
  }
  load_balancer_arn = aws_alb.my_alb.arn
  port = 80
  protocol = "HTTP"
}