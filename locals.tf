locals {
  control_planes = [
    for i, s in var.control_planes : {
      name        = "${s.name}-${format("%02d", i + 1)}"
      server_type = s.server_type
      location    = s.location
      private_ipv4 = cidrhost(
        hcloud_network_subnet.control_plane.ip_range, i + 101
      )
      labels = s.labels
      taints = s.taints
    }
  ]
  agents = flatten([
    for i, s in var.agent_nodepools : [
      for j in range(s.count) : {
        name        = "${s.name}-${format("%02d", j + 1)}"
        server_type = s.server_type
        location    = s.location
        private_ipv4 = cidrhost(
          hcloud_network_subnet.agent[[
            for i, v in var.agent_nodepools : i if v.name == s.name][0]
        ].ip_range, j + 101)
        labels      = s.labels
        taints      = s.taints
        volume_size = s.volume_size != null ? s.volume_size : 0
      }
    ]
  ])
  k3s_install_script = "curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_SELINUX_RPM=true ${"INSTALL_K3S_${var.initial_k3s_version != null ? "VERSION" : "CHANNEL"}=${coalesce(var.initial_k3s_version, var.initial_k3s_channel)}"} K3S_TOKEN=${random_password.k3s_token.result}"
  k3s_post_install_scripts = [
    "/sbin/semodule -v -i /usr/share/selinux/packages/k3s.pp",
    "restorecon -v /usr/local/bin/k3s",
  ]
  k3s_server_runcmd = concat(
    [
      "${local.k3s_install_script} sh -s - server"
    ],
    local.k3s_post_install_scripts,
    [
      "systemctl start k3s"
    ]
  )
  k3s_agent_runcmd = concat(
    [
      "systemctl enable --now iscsid",
      "${local.k3s_install_script} sh -s - agent"
    ],
    local.k3s_post_install_scripts,
    [
      "systemctl start k3s-agent"
    ]
  )
}
