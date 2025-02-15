module "agents" {
  for_each            = { for i, s in local.agents : s.name => s }
  source              = "./host"
  name                = "${var.cluster_name}-${each.key}"
  type                = each.value.server_type
  location            = each.value.location
  placement_group_id  = each.value.placement_group_id
  hcloud_firewall_ids = [hcloud_firewall.k3s.id]
  hcloud_ssh_keys     = var.hcloud_ssh_keys
  hcloud_network_id   = hcloud_network.k3s.id
  private_ipv4        = each.value.private_ipv4
  ssh_port            = var.ssh_port
  k3s_config = {
    server      = local.kupe_api_server_url
    node-ip     = each.value.private_ipv4
    node-label  = each.value.labels
    node-taint  = each.value.taints
    kubelet-arg = var.k3s_global_kubelet_args
  }
  runcmd = local.k3s_agent_runcmd
  hcloud_volumes = each.value.volume_size >= 10 ? [
    {
      name = "${var.cluster_name}-${each.key}"
      size = each.value.volume_size
    }
  ] : []
  depends_on = [module.first_control_plane]
}
