resource "hcloud_server" "agents" {
  for_each     = { for i, s in local.agents : s.name => s }
  name         = "${var.cluster_name}-${each.value.name}"
  image        = data.hcloud_image.microos_x86_snapshot.id
  server_type  = each.value.server_type
  location     = each.value.location
  firewall_ids = [hcloud_firewall.k3s.id]
  ssh_keys     = var.hcloud_ssh_keys
  depends_on   = [hcloud_server.first_control_plane]
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
      content = base64encode(yamlencode(
        {
          server      = local.control_planes[0].private_ipv4
          node-ip     = each.value.private_ipv4
          node-label  = each.value.labels
          node-taint  = each.value.taints
          kubelet-arg = var.k3s_global_kubelet_args
        }
      ))
    },
  ]
  runcmd = local.k3s_agent_runcmd
})}
EOT
}

resource "hcloud_server_network" "agents" {
  for_each   = [for i, s in local.agents : s]
  server_id  = hcloud_server.agents[each.key].id
  network_id = hcloud_network.k3s.id
  ip         = each.value.private_ipv4
}

resource "hcloud_volume" "volumes" {
  for_each  = [for i, s in local.agents : s if s.volume_size >= 10]
  name      = "${var.cluster_name}-${each.value.name}"
  size      = each.value.volume_size
  server_id = hcloud_server.agents[each.key].id
  automount = true
  format    = "ext4"
}
