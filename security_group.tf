resource "aws_security_group" "default" {
  count       = local.security_group_count
  name        = module.label.id
  vpc_id      = var.vpc_id
  description = "Instance default security group (only egress access is allowed)"

  tags = merge(
    module.label.tags,
    {
      Center  = var.center
      Project = var.project
      Creator = var.creator
    }
  )

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      cidr_blocks = [ingress.value]
      protocol    = "tcp"
    }
  }

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      cidr_blocks = [ingress.value]
      protocol    = "udp"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress" {
  count             = var.create_default_security_group ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default[0].id
}

resource "aws_security_group_rule" "allow-self" {
  count = local.sec_group_allow_self
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.default[0].id
  to_port = 0
  type = "ingress"
  self = true
}
