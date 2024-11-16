module "first_control_plane" {
  source              = "./host"
  name                = local.control_planes[0].name
  type                = local.control_planes[0].server_type
  location            = local.control_planes[0].location
  hcloud_firewall_ids = [hcloud_firewall.k3s.id]
  hcloud_ssh_keys     = var.hcloud_ssh_keys
  hcloud_network_id   = hcloud_network.k3s.id
  private_ipv4        = local.control_planes[0].private_ipv4
  ssh_port            = var.ssh_port
  k3s_config = merge(
    var.control_planes_custom_config,
    {
      cluster-init = true
      node-ip      = local.control_planes[0].private_ipv4
      node-label   = local.control_planes[0].labels
      node-taint   = local.control_planes[0].taints
      kubelet-arg  = var.k3s_global_kubelet_args
    }
  )
  runcmd = local.k3s_server_runcmd
}
