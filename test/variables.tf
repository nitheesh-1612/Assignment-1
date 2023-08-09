variable "service_account" {
  default = null
  type = object({
    email  = string
    scopes = set(string)
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account."
}

variable "machine_type" {
    type = string
}

variable "project_id" {
  type = string
}

variable "network_name" {
  type = string
}

variable "public_subnet" {
  type = string
}

variable "private_subnet" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "image" {
  type = string
}

variable "image_family" {
  type = string
}

variable "image_project" {
  type = string
}

variable "network_tier" {
  description = "Network network_tier"
  default     = "PREMIUM"
}

variable "routing_mode" {
  type        = string
  default     = "GLOBAL"
  description = "The network routing mode (default 'GLOBAL')"
}

variable "shared_vpc_host" {
  type        = bool
  description = "Makes this project a Shared VPC host if 'true' (default 'false')"
  default     = false
}