locals {
  instance_count       = var.instance_enabled ? 1 : 0
  on_demand            = var.on_demand_enabled ? 1 : 0
  role_count           = var.role_enabled ? 1 : 0
  cloudwatch_count     = var.cloudwatch_enabled ? 1 : 0
  security_group_count = var.create_default_security_group ? 1 : 0
  consul_agent_count   = var.consul_agent_enabled ? 1 : 0
  region               = var.region != "" ? var.region : data.aws_region.default.name
  root_iops            = var.root_volume_type == "gp2" ? var.root_iops : "0"
  ebs_iops             = var.ebs_volume_type == "gp2" ? var.ebs_iops : "0"
  availability_zone    = var.availability_zone != "" ? var.availability_zone : data.aws_subnet.default.availability_zone
  ami                  = var.ami != "" ? var.ami : data.aws_ami.default.image_id
  ami_owner            = var.ami != "" ? var.ami_owner : data.aws_ami.default.owner_id
  root_volume_type     = var.root_volume_type != "" ? var.root_volume_type : data.aws_ami.default.root_device_type
  sec_group_allow_self = var.security_group_allow_self ? 1 : 0
  //  public_dns           = var.associate_public_ip_address && var.assign_eip_address && var.instance_enabled ? data.null_data_source.eip.outputs["public_dns"] : join("", aws_instance.default.*.public_dns)
}

data "aws_caller_identity" "default" {
}

data "aws_region" "default" {
}

data "aws_subnet" "default" {
  id = var.subnet
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_ami" "default" {
  most_recent = "true"

  filter {
    name   = "image-id"
    values = [var.ami]
  }

  owners = [var.ami_owner]
}

//data "aws_ami" "info" {
//  filter {
//    name   = "image-id"
//    values = [local.ami]
//  }
//
//  owners = [local.ami_owner]
//}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  delimiter  = var.delimiter
  enabled    = var.instance_enabled
  tags       = var.tags
}

resource "aws_iam_instance_profile" "default" {
  count = local.role_count
  name  = module.label.id
  role  = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role" "default" {
  count              = local.role_count
  name               = module.label.id
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_instance" "default" {
  count                       = local.on_demand
  ami                         = local.ami
  availability_zone           = local.availability_zone
  instance_type               = var.instance_type
  ebs_optimized               = var.ebs_optimized
  disable_api_termination     = var.disable_api_termination
  user_data                   = var.user_data
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.ssh_key_pair
  subnet_id                   = var.subnet
  monitoring                  = var.monitoring
  private_ip                  = var.private_ip
  source_dest_check           = var.source_dest_check
  ipv6_address_count          = var.ipv6_address_count
  ipv6_addresses              = var.ipv6_addresses

  vpc_security_group_ids = compact(
    concat(
      [
        var.create_default_security_group ? join("", aws_security_group.default.*.id) : "",
      ],
      var.security_groups
    )
  )

  root_block_device {
    volume_type           = local.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = local.root_iops
    delete_on_termination = var.delete_on_termination
  }

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${aws_instance.default[count.index].root_block_device[0].volume_id} --region ${var.region} --tags Key=Name,Value=${var.name} Key=Center,Value=${var.center} Key=Project,Value=${var.project} Key=Creator,Value=${var.creator}"
  }

  tags = merge(
    module.label.tags,
    {
      Center  = var.center
      Project = var.project
      Creator = var.creator
    }, var.creator_tag
  )

  lifecycle {
    ignore_changes = [security_groups]
  }

}

resource "aws_spot_instance_request" "cheap_worker" {
  count                           = local.on_demand == 1 ? 0 : 1
  ami                             = var.ami
  spot_price                      = var.spot_instance_price
  availability_zone               = local.availability_zone
  spot_type                       = var.spot_type
  instance_interruption_behaviour = var.instance_interruption_behaviour
  wait_for_fulfillment            = var.spot_wait_for_fulfillment
  valid_until                     = var.spot_valid_until
  instance_type                   = var.instance_type
  private_ip                      = var.private_ip
  associate_public_ip_address     = var.associate_public_ip_address
  subnet_id                       = var.subnet
  user_data                       = var.user_data
  key_name                        = var.ssh_key_pair
  ebs_optimized                   = var.ebs_optimized
  iam_instance_profile            = var.iam_instance_profile

  vpc_security_group_ids = compact(
    concat(
      [
        var.create_default_security_group ? join("", aws_security_group.default.*.id) : "",
      ],
      var.security_groups
    )
  )

  root_block_device {
    volume_type           = local.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = local.root_iops
    delete_on_termination = var.delete_on_termination
  }

  tags = merge(
    module.label.tags,
    {
      Center  = var.center
      Project = var.project
      Creator = var.creator
    }, var.creator_tag
  )

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${aws_spot_instance_request.cheap_worker[count.index].root_block_device[0].volume_id} --region ${var.region} --tags Key=Name,Value=${var.name} Key=Center,Value=${var.center} Key=Project,Value=${var.project} Key=Creator,Value=${var.creator}"
  }

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${aws_spot_instance_request.cheap_worker[count.index].spot_instance_id} --region ${var.region} --tags Key=Name,Value=${var.name} Key=Center,Value=${var.center} Key=Project,Value=${var.project} Key=Creator,Value=${var.creator}"
  }

  lifecycle {
    ignore_changes = [security_groups]
  }
}

resource "aws_eip" "default" {
  count             = var.associate_public_ip_address && var.assign_eip_address && var.instance_enabled ? 1 : 0
  network_interface = join("", aws_instance.default.*.primary_network_interface_id)
  vpc               = true
  tags = merge(
    module.label.tags,
    {
      Center  = var.center
      Project = var.project
      Creator = var.creator
    }, var.creator_tag
  )
}

data "null_data_source" "eip" {
  count = var.associate_public_ip_address && var.assign_eip_address ? 1 : 0
  inputs = {
    public_dns = "ec2-${replace(join("", aws_eip.default.*.public_ip), ".", "-")}.${local.region == "ap-southeast-1" ? "compute-1" : "${local.region}.compute"}.amazonaws.com"
  }
}

resource "aws_ebs_volume" "default" {
  count             = var.ebs_volume_count
  availability_zone = local.availability_zone
  size              = var.ebs_volume[count.index].size
  iops              = lookup(var.ebs_volume[count.index], "iops", "0")
  type              = lookup(var.ebs_volume[count.index], "type", "gp2")
  tags = merge(
    module.label.tags,
    {
      Center  = var.center
      Project = var.project
      Creator = var.creator
    }, var.creator_tag
  )
}

resource "aws_volume_attachment" "default" {
  count       = var.ebs_volume_count
  device_name = var.ebs_device_name[count.index]
  volume_id   = aws_ebs_volume.default.*.id[count.index]
  instance_id = local.on_demand == 1 ? join("", aws_instance.default.*.id) : join("", aws_spot_instance_request.cheap_worker[count.index].spot_instance_id)
}

resource "local_file" "hosts-ini" {
  count    = local.consul_agent_count
  filename = "${path.module}/ansible/hosts.ini"
  content  = "[consul-master]\n%{for i in var.consul_master_hosts}${i}\n%{endfor}\n[consul-agent]\n${var.private_ip}"
}

resource "null_resource" "consul-agent-deploy" {
  count = local.consul_agent_count
  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/ansible/hosts.ini ${path.module}/ansible/consul.yaml -b -vvvv"
  }
}
