output "lb_dns_name" {
  description = "Load Balancer DNS Name"
  value = aws_alb.my_alb.dns_name
}