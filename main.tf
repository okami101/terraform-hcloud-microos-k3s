data "hcloud_image" "microos_x86_snapshot" {
  with_selector     = "microos-snapshot=yes"
  with_architecture = "x86"
  most_recent       = true
}

locals {
  network_ipv4_subnets = [
    for index in range(256) : cidrsubnet(var.network_ipv4_cidr, 8, index)
  ]
}

resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

resource "hcloud_network" "k3s" {
  name     = var.cluster_name
  ip_range = var.network_ipv4_cidr
}

resource "hcloud_network_subnet" "control_plane" {
  network_id   = hcloud_network.k3s.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = local.network_ipv4_subnets[255]
}

resource "hcloud_network_subnet" "agent" {
  count        = length(var.agent_nodepools)
  network_id   = hcloud_network.k3s.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = local.network_ipv4_subnets[count.index]
}

resource "hcloud_firewall" "k3s" {
  name = var.cluster_name

  rule {
    description = "Allow access to the kube API"
    direction   = "in"
    protocol    = "tcp"
    port        = 6443
    source_ips  = var.firewall_kube_api_source
  }

  rule {
    description = "Allow SSH access"
    direction   = "in"
    protocol    = "tcp"
    port        = var.ssh_port
    source_ips  = var.firewall_ssh_source
  }
}
