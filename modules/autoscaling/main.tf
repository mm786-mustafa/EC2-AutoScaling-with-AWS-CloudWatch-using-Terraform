data "aws_region" "current" {} # Fetching Current Region

# *** Launch Template ***
resource "aws_launch_template" "launch_template" {
  name = "${var.environment}-${var.launch_template_name}-${data.aws_region.current.name}"
  instance_type = var.instance_type
  image_id = var.image_id
  key_name = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install php7.4 -y
    sudo yum install httpd -y
    sudo yum install mysql -y
    sudo yum install php-mysqlnd php-fpm php-json php-xml php-gd php-mbstring -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    wget https://wordpress.org/latest.tar.gz
    tar -xvzf latest.tar.gz
    sudo mv wordpress/* /var/www/html/
    sudo chown -R apache:apache /var/www/html/
    sudo systemctl restart httpd
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sudo sed -i "s/database_name_here/${var.rds_db_name}/" /var/www/html/wp-config.php
    sudo sed -i "s/username_here/${var.rds_username}/" /var/www/html/wp-config.php
    sudo sed -i "s/password_here/${var.rds_password}/" /var/www/html/wp-config.php
    sudo sed -i "s/localhost/${split(":",var.rds_endpoint)[0]}/" /var/www/html/wp-config.php
    sudo systemctl restart httpd
    EOF
  )
  tags = {
    Name = "${var.environment}-${var.launch_template_name}-${data.aws_region.current.name}"
  }
}

# *** Autoscaling Group ***
resource "aws_autoscaling_group" "autoscaling_group" {
  name = "${var.environment}-${var.autoscaling_group_name}-${data.aws_region.current.name}"
  # availability_zones = var.availability_zones
  desired_capacity_type = var.asg_desired_capacity_type
  desired_capacity = var.asg_desired_capacity
  max_size = var.asg_max_size
  min_size = var.asg_min_size
  health_check_type = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns = [ var.target_group_arn ]

  launch_template {
    id = aws_launch_template.launch_template.id
  }

  tag {
    key = "Name"
    value = "${var.environment}-${var.autoscaling_group_name}-${data.aws_region.current.name}"
    propagate_at_launch = true
  }
}

# *** CPU Target Tracking Policy ***
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.environment}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0 # Set your desired target CPU utilization
  }
}

# *** High CPU Alarm ***
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name        = "${var.environment}-high-cpu-alarm"
  alarm_description = "Alarm to scale up when CPU usage exceeds 80% for 5 minutes"
  namespace         = "AWS/EC2"
  metric_name       = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_autoscaling_policy.cpu_target_tracking.arn]
}

# *** Low CPU Alarm ***
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name        = "${var.environment}-low-cpu-alarm"
  alarm_description = "Alarm to scale down when CPU usage is below 40% for 10 minutes"
  namespace         = "AWS/EC2"
  metric_name       = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
  statistic           = "Average"
  period              = 600
  evaluation_periods  = 1
  threshold           = 40
  comparison_operator = "LessThanThreshold"
  alarm_actions       = [aws_autoscaling_policy.cpu_target_tracking.arn]
}