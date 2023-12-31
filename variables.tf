#1 Create a Region
variable "region" {
  type        = string
  description = "Variable for aws region"
  default     = "us-east-1"

}

#2 Create a named profile
variable "profile" {
  type        = string
  description = "Variable for aws profile"
  default     = "obinna"

}

#3 Create a vpc cidr block variable
variable "vpc_cidr" {
  type        = string
  description = "Variable for VPC cidr block"
  default     = "10.0.0.0/16"

}

#4 Create a public subnet az1 cidr block variable
variable "public_subnet_az1_cidr_block" {
  type        = string
  description = "Variable for Public Subnet az1 cidr block"
  default     = "10.0.0.0/24"
}


#5 Create a public subnet az2 cidr block variable
variable "public_subnet_az2_cidr_block" {
  type        = string
  description = "Variable for Public Subnet az2 cidr block"
  default     = "10.0.1.0/24"
}



#6 Create a private app subnet az1 cidr block variable
variable "private_app_subnet_az1_cidr_block" {
  type        = string
  description = "Variable for private app subnet az1"
  default     = "10.0.2.0/24"
}

#7 Create a private app subnet az2 cidr block variable
variable "private_app_subnet_az2_cidr_block" {
  type        = string
  description = "Variable for private app subnet az2"
  default     = "10.0.3.0/24"
}

#8 Create a private data subnet az1 cidr block variable
variable "private_data_subnet_az1_cidr_block" {
  type        = string
  description = "Variable for private data subnet az1"
  default     = "10.0.4.0/24"
}


#9 Create a private data subnet az2 cidr block variable
variable "private_data_subnet_az2_cidr_block" {
  type        = string
  description = "Variable for private data subnet az2"
  default     = "10.0.5.0/24"
}

#10 Create a availability zones
variable "availability_zones" {
  type        = list(string)
  description = "A variable for azs"
  default     = ["us-east-1a", "us-east-1b"]
}

#11 Create a Security Group Variable
variable "ssh_security_group_cidr_blocks" {
  type        = list(string)
  description = "SSH Security Group cidr blocks"
  default     = ["89.64.80.15/32"]
}

#12 Create a RDS Variables
variable "db_snapshot_identifier" {
  type        = string
  description = "DB snapshot identifier"
  default     = "arn:aws:rds:us-east-1:612500737416:snapshot:fleetcart-db-snapshot"
}

variable "db_identifier" {
  type        = string
  description = "DB identifier for mysql rds"
  default     = "fleetcart-id" #get this from the snapshot

}
variable "database_instance_class" {
  type        = string
  description = "DB instance class for mysql rds"
  default     = "db.t3.micro" #get this from the snapshot

}



#13 Certificate Manager Variables
variable "ssl_certificate_arn" {
  type        = string
  description = "Certificate Manager ARN"
  default     = "arn:aws:acm:us-east-1:612500737416:certificate/2d80a295-a450-442b-88d7-b9f317930f45"
}

##14 Create SNS variables

variable "sns_endpoint" {
  type        = string
  description = "SNS endpoint which is email address"
  default     = "wiz.obi7509@gmail.com"
}

##15 Create Route53 Variables
variable "hosted_zone" {
  type        = string
  description = "DNS hosted zone which is our domain name"
  default     = "wiz-obi.com"
}

variable "a_record" {
  type        = string
  description = "Site domain name or A record"
  default     = "www" #you can also use "app", "webapp" etc
}


#Create ASG Variables
variable "instance_type" {
  type        = string
  description = "Instance Type for auto scaling group"
  default     = "t2.micro"
}

variable "key_name" {
  type = string
  description = "SSH key pair"
  default = "html-key"
}