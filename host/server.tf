data "hcloud_image" "microos_x86_snapshot" {
  with_selector     = "microos-snapshot=yes"
  with_architecture = "x86"
  most_recent       = true
}

data "hcloud_image" "microos_arm_snapshot" {
  with_selector     = "microos-snapshot=yes"
  with_architecture = "arm"
  most_recent       = true
}

resource "hcloud_server" "server" {
  name         = var.name
  server_type  = var.type
  location     = var.location
  image        = substr(var.type, 0, 3) == "cax" ? data.hcloud_image.microos_arm_snapshot.id : data.hcloud_image.microos_x86_snapshot.id
  firewall_ids = var.hcloud_firewall_ids
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
      content     = base64encode(yamlencode(var.k3s_config))
    },
  ]
  runcmd = var.runcmd
})}
EOT
}

resource "hcloud_server_network" "server" {
  ip         = var.private_ipv4
  server_id  = hcloud_server.server.id
  network_id = var.hcloud_network_id
}

resource "hcloud_volume" "volumes" {
  for_each  = { for i, s in var.hcloud_volumes : i => s if s.size >= 10 }
  name      = "${var.name}-${each.value.name}"
  size      = each.value.size
  server_id = hcloud_server.server.id
  automount = true
  format    = "ext4"
}
