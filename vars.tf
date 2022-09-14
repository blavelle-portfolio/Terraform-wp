variable aws_reg {
  description = "This is aws region"
  default     = "us-east-2"
  type        = string
}

variable stack {
  description = "this is name for tags"
  default     = "wordpress"
}

variable username {
  description = "DB username"
}

variable password {
  description = "DB password"
}

variable db_name {
  description = "db name"
}

variable ami {
  default = "ami-0f0bfa4c961a61b8f"
  description = "default ubuntu AMI"

}