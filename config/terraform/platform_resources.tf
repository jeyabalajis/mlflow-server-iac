resource "aws_security_group" "platform-sg" {
  vpc_id = var.platform_vpc_id
  tags   = merge(tomap({ Name = "platform security group" }), var.platform_tags)
}
