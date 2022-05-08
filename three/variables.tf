variable "cidr"{
type = string
default = "10.0.0.0/16"
}

variable "subnet_cidr"{
type = list
default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "az"{
type = list
default =["ap-south-1a" , "ap-south-1b" , "ap-south-1c"]
}

variable "ami"{
default = "ami-0a3277ffce9146b74"
}

variable "type"{
type = list
default = ["t2.micro" , "t2.small" , "t2.medium"]
}