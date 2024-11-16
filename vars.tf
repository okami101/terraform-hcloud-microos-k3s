variable "cluster_name" {
  description = "The cluster name, will be used in the node name, in the form of {cluster_name}-{nodepool_name}"
  type        = string
  default     = "k3s"
}

variable "network_zone" {
  description = "The network zone where to attach hcloud resources"
  type        = string
  default     = "eu-central"
}

variable "network_ipv4_cidr" {
  description = "The main network cidr that all subnets will be created upon."
  type        = string
  default     = "10.0.0.0/8"
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

variable "firewall_kube_api_source" {
  description = "IP sources that are allowed to access the kube API"
  type        = list(string)
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
}

variable "firewall_ssh_source" {
  description = "IP sources that are allowed to access the servers via SSH"
  type        = list(string)
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
}

variable "initial_k3s_channel" {
  description = "K3S channel to use for the installation"
  type        = string
  default     = "stable"
}

variable "initial_k3s_version" {
  description = "K3S version to use for the installation, superseeds initial_k3s_channel"
  type        = string
  default     = null
}

variable "k3s_global_kubelet_args" {
  description = "Additional arguments for each kubelet service"
  type        = list(string)
  default     = []
}

variable "control_planes_custom_config" {
  description = "Custom control plane k3s server configuration"
  type        = any
  default     = {}
}

variable "control_planes" {
  description = "List of control planes"
  type = list(object({
    name        = string
    server_type = string
    location    = string
    labels      = list(string)
    taints      = list(string)
  }))
}

variable "agent_nodepools" {
  description = "List of all additional worker types to create for k3s cluster. Each type is identified by specific role and can have a different number of instances."
  type = list(object({
    name        = string
    server_type = string
    location    = string
    count       = number
    labels      = list(string)
    taints      = list(string)
    volume_size = optional(number)
  }))
}
