data "aws_region" "current" {} # Fetching Current Region

# *** Target Group for Load Balancer ***
resource "aws_lb_target_group" "my_target_group" {
  name = "${var.target_group_name}-${var.environment}"
  target_type = "instance"
  protocol = "HTTP"
  port = 80
  vpc_id = var.vpc_id
  health_check {
    path = "/wp-admin/install.php"
  }
  tags = {
    Name = "${var.environment}-${var.target_group_name}-${data.aws_region.current.name}"
  }
}