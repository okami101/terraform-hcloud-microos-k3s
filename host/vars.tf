variable "location" {
  description = "The location to use for the servers"
  type        = string
}

variable "type" {
  description = "The server type to use for the servers"
  type        = string
}

variable "name" {
  description = "The name to use for the servers"
  type        = string
}

variable "hcloud_ssh_keys" {
  description = "List of hcloud SSH keys that will be used to access the servers"
  default     = []
  type        = list(string)
}

variable "ssh_port" {
  description = "The SSH port to use for the servers"
  default     = 22
  type        = number
}

variable "hcloud_firewall_ids" {
  description = "List of firewall IDs to attach to the server"
  type        = list(number)
  default     = []
}

variable "runcmd" {
  description = "List of commands to run after the first boot"
  default     = []
  type        = list(string)
}

variable "k3s_config" {
  description = "K3S configuration"
  type        = any
  default     = {}
}

variable "private_ipv4" {
  description = "The private IPv4 address to use for the server"
  type        = string
}

variable "hcloud_subnet_id" {
  description = "The subnet ID to use for the server"
  type        = number
}

variable "hcloud_volumes" {
  description = "List of volumes to attach to the server"
  type = list(object({
    name = string
    size = number
  }))
  default = []
}
