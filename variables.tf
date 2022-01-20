variable "ssh_key_pair" {
  type        = string
  description = "SSH key pair to be provisioned on the instance"
  default     = "default"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with the instance"
  default     = false
}

variable "assign_eip_address" {
  type        = bool
  description = "Assign an Elastic IP address to the instance"
  default     = false
}

variable "user_data" {
  type        = string
  description = "Instance user data. Do not pass gzip-compressed data via this argument"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "The type of the instance"
  default     = "t2.micro"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC that the instance security group belongs to"
}

variable "security_groups" {
  description = "List of Security Group IDs allowed to connect to the instance"
  type        = list(string)
  default     = []
}

variable "allowed_ports" {
  type        = map(string)
  description = "map of allowed ingress ports"
  default = {
    // port     = cidr_block
    0 = "0.0.0.0/0"
  }
}

variable "subnet" {
  type        = string
  description = "VPC Subnet ID the instance is launched in"
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `cp` or `cloudposse`)"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`"
  default     = ""
}

variable "name" {
  type        = string
  description = "Name  (e.g. `bastion` or `db`)"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  description = "Additional attributes (e.g. `1`)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS Region the instance is launched in"
  default     = "ap-southeast-1"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone the instance is launched in. If not set, will be launched in the first AZ of the region"
  default     = ""
}

variable "ami" {
  type        = string
  description = "The AMI to use for the instance. By default it is the AMI provided by Amazon with Ubuntu 16.04"
  default     = ""
}

variable "ami_owner" {
  type        = string
  description = "Owner of the given AMI (ignored if `ami` unset)"
  default     = ""
}

variable "ebs_optimized" {
  type        = bool
  description = "Launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "disable_api_termination" {
  type        = bool
  description = "Enable EC2 Instance Termination Protection"
  default     = false
}

variable "monitoring" {
  type        = bool
  description = "Launched EC2 instance will have detailed monitoring enabled"
  default     = true
}

variable "private_ip" {
  type        = string
  description = "Private IP address to associate with the instance in the VPC"
  default     = ""
}

variable "source_dest_check" {
  type        = bool
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs"
  default     = true
}

variable "ipv6_address_count" {
  type        = number
  description = "Number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet"
  default     = 0
}

variable "ipv6_addresses" {
  type        = list(string)
  description = "List of IPv6 addresses from the range of the subnet to associate with the primary network interface"
  default     = []
}

variable "root_volume_type" {
  type        = string
  description = "Type of root volume. Can be standard, gp2 or io1"
  default     = "gp2"
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in gigabytes"
  default     = 30
}

variable "root_iops" {
  type        = number
  description = "Amount of provisioned IOPS. This must be set if root_volume_type is set to `io1`"
  default     = 0
}

variable "ebs_device_name" {
  type        = list(string)
  description = "Name of the EBS device to mount"
  default     = ["/dev/xvdb", "/dev/xvdc", "/dev/xvdd", "/dev/xvde", "/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj", "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo", "/dev/xvdp", "/dev/xvdq", "/dev/xvdr", "/dev/xvds", "/dev/xvdt", "/dev/xvdu", "/dev/xvdv", "/dev/xvdw", "/dev/xvdx", "/dev/xvdy", "/dev/xvdz"]
}

variable "ebs_volume_type" {
  type        = string
  description = "The type of EBS volume. Can be standard, gp2 or io1"
  default     = "gp2"
}

variable "ebs_volume_size" {
  type        = number
  description = "Size of the EBS volume in gigabytes"
  default     = 50
}

variable "ebs_iops" {
  type        = number
  description = "Amount of provisioned IOPS. This must be set with a volume_type of io1"
  default     = 0
}

variable "ebs_volume_count" {
  type        = number
  description = "Count of EBS volumes that will be attached to the instance"
  default     = 0
}

variable "delete_on_termination" {
  type        = bool
  description = "Whether the volume should be destroyed on instance termination"
  default     = true
}

variable "welcome_message" {
  type        = string
  default     = ""
  description = "Welcome message"
}

variable "comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold. Possible values are: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold."
  default     = "GreaterThanOrEqualToThreshold"
}

variable "metric_name" {
  type        = string
  description = "The name for the alarm's associated metric. Allowed values can be found in https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ec2-metricscollected.html"
  default     = "StatusCheckFailed_Instance"
}

variable "evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 5
}

variable "metric_namespace" {
  type        = string
  description = "The namespace for the alarm's associated metric. Allowed values can be found in https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-namespaces.html"
  default     = "AWS/EC2"
}

variable "applying_period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied"
  default     = 60
}

variable "statistic_level" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric. Allowed values are: SampleCount, Average, Sum, Minimum, Maximum"
  default     = "Maximum"
}

variable "metric_threshold" {
  type        = number
  description = "The value against which the specified statistic is compared"
  default     = 1
}

variable "default_alarm_action" {
  type        = string
  default     = "action/actions/AWS_EC2.InstanceId.Reboot/1.0"
  description = "Default alerm action"
}

variable "create_default_security_group" {
  type        = bool
  description = "Create default Security Group with only Egress traffic allowed"
  default     = true
}

variable "instance_enabled" {
  type        = bool
  description = "Flag to control the instance creation. Set to false if it is necessary to skip instance creation"
  default     = true
}

variable "on_demand_enabled" {
  type        = bool
  description = "Flag to control the instance creation. Set to false if it is necessary to skip instance creation"
  //default     = true
}

variable "additional_ips_count" {
  type        = number
  description = "Count of additional EIPs"
  default     = 0
}

variable "role_enabled" {
  type        = bool
  description = "role_enabled"
  default     = false
}

variable "cloudwatch_enabled" {
  type        = bool
  description = "cloudwatch_enabled"
  default     = false
}


variable "center" {
  type        = string
  description = "Name of center. Ex: dc1, dc2, dc3 ..."
}

variable "project" {
  type        = string
  description = "Name of project. Ex: pd, checkout, ..."
}

variable "creator" {
  type        = string
  description = "Name of creator ..."
}
//
//variable "env_sec_group" {
//  type = map(string)
//  default = {
//    test       = ""
//    staging    = ""
//    production = ""
//  }
//}

variable "creator_tag" {
  type        = map(string)
  description = "Allow creator add more tag"
  default     = {}
}

variable "consul_agent_enabled" {
  default     = false
  type        = bool
  description = "Enabled install consul-agent"
}

variable "consul_master_hosts" {
  type        = list(string)
  default     = []
  description = "List of consul master"
}

variable "spot_instance_enabled" {
  default     = false
  type        = bool
  description = "Enabled spot instance request"
}

variable "spot_instance_price" {
  default     = ""
  type        = string
  description = "Spot price of instance"
}

variable "spot_type" {
  default = "persistent"
  type    = string
}

variable "instance_interruption_behaviour" {
  default = "stop"
  type    = string
}

variable "spot_wait_for_fulfillment" {
  default = true
  type    = bool
}

variable "spot_valid_until" {
  default     = "2030-02-22T22:02:22Z"
  type        = string
  description = "The default end date is 7 days from the current date. format(for example, YYYY-MM-DDTHH:MM:SSZ)"
}

variable "security_group_allow_self" {
  type = bool
  default = false
  description = "Security group allow self ALL port"
}

variable "iam_instance_profile" {
  default = ""
  type = string
  description = "IAM instance profile"
}

variable "ebs_volume" {
  type = list(map(string))
  default = []
  description = "ebs_volume for multi specific"
}