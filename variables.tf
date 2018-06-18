variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloudposse`) - required for `terraform-terraform-label` module"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging` - required for `terraform-terraform-label` module"
}

variable "name" {
  description = "Name  (e.g. `bastion` or `db`) - required for `terraform-terraform-label` module"
}

variable "tags" {
  type        = "map"
  description = "A map of all additional tags to add to resources"
  default     = {}
}

variable "delimiter" {
  default = "-"
}

variable "sns_topic_arn" {
  description = "An SNS topic ARN that has already been created. Its policy must already allow access from CloudWatch Alarms, or set `add_sns_policy` to `true`"
  default     = ""
  type        = "string"
}

variable "add_sns_policy" {
  description = "Attach a policy that allows the notifications through to the SNS topic endpoint"
  default     = "false"
  type        = "string"
}

variable "allocation_strategy" {
  type        = "string"
  description = "Allocation strategy options: diversified, lowestPrice"
  default     = "diversified"
}

variable "existing_cluster_name" {
  type        = "string"
  description = "The name of an existing ECS cluster that should be joined"
  default     = ""
}

variable "cluster_label" {
  type        = "string"
  description = "If a new cluster is generated, it will use the name [namespace]-[stage]-[name]-[attributes] unless overridden with a new string here"
  default     = ""
}

variable "attributes" {
  description = "Additional attributes (e.g. `policy` or `role`)"
  type        = "list"
  default     = []
}

variable "iam_instance_profile_arn" {
  type        = "string"
  description = "An iam instance profile arn to use, instead of creating one"
  default     = ""
}

variable "additional_user_data" {
  type        = "string"
  description = "User data that will run at the end of the existing user data"
  default     = ""
}

variable "spot_price" {
  type        = "string"
  description = "(Default: On-demand price) The maximum bid price per unit hour."
  default     = ""
}

variable "target_capacity" {
  type        = "string"
  description = "The number of units to request. You can choose to set the target capacity in terms of instances or a performance characteristic that is important to your application workload, such as vCPUs, memory, or I/O."
  default     = "3"
}

variable "instance_type_list" {
  type        = "list"
  description = "A list of named instance sizes for the spot fleet"
  default     = ["c3.large", "c4.large", "m3.large", "m4.large", "m5.large", "r3.large", "r4.large", "c5.large", "i3.large"]
}

variable "wait_for_fulfillment" {
  type        = "string"
  description = "When true Terraform waits for the spot request to be fulfilled"
  default     = "true"
}

variable "replace_unhealthy_instances" {
  type        = "string"
  description = "Indicates whether Spot fleet should replace unhealthy instances. Default true."
  default     = "true"
}

variable "valid_until" {
  type        = "string"
  description = "The end date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ). At this point, no new Spot instance requests are placed or enabled to fulfill the request. Defaults to 24 hours."
  default     = ""
}

variable "terminate_instances_with_expiration" {
  type        = "string"
  description = "Indicates whether running Spot instances should be terminated when the Spot fleet request expires."
  default     = ""
}

variable "excess_capacity_termination_policy" {
  type        = "string"
  description = "Indicates whether running Spot instances should be terminated if the target capacity of the Spot fleet request is decreased below the current size of the Spot fleet"
  default     = ""
}

variable "instance_interruption_behavior" {
  type        = "string"
  description = "Indicates whether a Spot instance stops or terminates when it is interrupted. Default is terminate. Options hibernate | stop | terminate"
  default     = "terminate"
}

variable "ami_id" {
  type        = "string"
  description = "AMI id for use in the cluster"
  default     = ""
}

variable "load_balancers" {
  type        = "list"
  description = "A list of elastic load balancer names to add to the Spot fleet."
  default     = []
}

variable "target_group_arns" {
  type        = "list"
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  default     = []
}

variable "existing_key_pair_name" {
  type        = "string"
  description = "An existing keypair name to use"
  default     = ""
}

variable "generate_key_pair" {
  type        = "string"
  description = "Generate a new key pair when true"
  default     = "false"
}

variable "cidr_range_for_ssh_access" {
  type        = "string"
  description = "CIDR range for allowing SSH access in"
  default     = "0.0.0.0/0"
}

variable "ebs_optimized" {
  type        = "string"
  description = "Instances should be EBS optimized. Default is false"
  default     = "false"
}

variable "placement_group" {
  type        = "string"
  description = "Specify a placement group name"
  default     = ""
}

variable "monitoring" {
  type        = "string"
  description = "Enable detailed monitoring. Default false"
  default     = "false"
}

variable "vpc_id" {
  type        = "string"
  description = "The VPC id that the cluster will belong to"
}

variable "subnet_ids" {
  type        = "list"
  description = "A list of the subnet ids that your cluster will belong to"
}

variable "map_public_ip_on_launch" {
  type        = "string"
  description = "Give the ec2 server a public IP address when it launches"
  default     = "true"
}

variable "security_group_ids" {
  type        = "list"
  description = "Additional security group ids to add to the instances"
  default     = []
}

variable "outbound_traffic_cidr" {
  type        = "string"
  description = "CIDR block where egress traffic from the instances can reach"
  default     = "0.0.0.0/0"
}
