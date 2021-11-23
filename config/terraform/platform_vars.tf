variable "global_region" {
  description = "global region for aws deployment"
}

variable "account_id" {
  description = "account id"
}

variable "team" {
  description = "Team name"
}

variable "account_key" {
  description = "Team key"
}

variable "account_group" {
  description = "Team group"
}

variable "team_tags" {
  type        = map(string)
  description = "Common tags for the team"
}

variable "platform_vpc_id" {
  description = "The platform vpc id"
}

variable "platform_private_subnet_ids" {
  description = "The platform subnet ids"
}

variable "platform_tags" {
  type        = map(string)
  description = "Common tags for platform resources"
}

variable "key_name_prefix" {
  description = "The prefix for the randomly generated name for the AWS key pair to be used for SSH connections (e.g. `pulsar-terraform-ssh-keys-0a1b2cd3`)"
  default     = "pulsar-terraform-ssh-keys"
}

variable "aws_key_pair_id" {
  description = "share-bastion-us-east-1-v1"
}

variable "ec2_region" {
  description = "The region for the EC2 instances"
}
