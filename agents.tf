module "agents" {
  for_each            = [for i, s in local.agents : s]
  source              = "./host"
  name                = each.value.name
  type                = each.value.server_type
  location            = each.value.location
  hcloud_firewall_ids = [hcloud_firewall.k3s.id]
  hcloud_ssh_keys     = var.hcloud_ssh_keys
  hcloud_network_id   = hcloud_network.k3s.id
  private_ipv4        = each.value.private_ipv4
  ssh_port            = var.ssh_port
  k3s_config = {
    server      = local.control_planes[0].private_ipv4
    node-ip     = each.value.private_ipv4
    node-label  = each.value.labels
    node-taint  = each.value.taints
    kubelet-arg = var.k3s_global_kubelet_args
  }
  runcmd = local.k3s_agent_runcmd
  hcloud_volumes = each.value.volume_size >= 10 ? [
    {
      name = each.value.name
      size = each.value.volume_size
    }
  ] : []
}
