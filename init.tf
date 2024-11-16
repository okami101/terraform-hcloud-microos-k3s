resource "hcloud_server" "first_control_plane" {
  name         = "${var.cluster_name}-${local.control_planes[0].name}"
  image        = data.hcloud_image.microos_x86_snapshot.id
  server_type  = local.control_planes[0].server_type
  location     = local.control_planes[0].location
  firewall_ids = [hcloud_firewall.k3s.id]
  ssh_keys     = var.hcloud_ssh_keys
  lifecycle {
    ignore_changes = [
      firewall_ids,
      user_data,
      ssh_keys,
      image
    ]
  }
  user_data = <<-EOT
#cloud-config
${yamlencode({
  write_files = [
    local.ssh_custom_config,
    local.transactional_update_custom_config,
    {
      path        = "/etc/rancher/k3s/config.yaml"
      encoding    = "b64"
      permissions = "0644"
      content = base64encode(yamlencode(merge(
        var.control_planes_custom_config,
        {
          cluster-init = true
          node-ip      = local.control_planes[0].private_ipv4
          node-label   = local.control_planes[0].labels
          node-taint   = local.control_planes[0].taints
          kubelet-arg  = var.k3s_global_kubelet_args
        }
      )))
    },
  ]
  runcmd = local.k3s_server_runcmd
})}
EOT
}

resource "hcloud_server_network" "first_control_plane" {
  server_id  = hcloud_server.first_control_plane.id
  network_id = hcloud_network.k3s.id
  ip         = local.control_planes[0].private_ipv4
}
