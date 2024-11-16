locals {
  ssh_custom_config = {
    content     = <<-EOT
Port ${var.ssh_port}
PasswordAuthentication no
EOT
    path        = "/etc/ssh/sshd_config.d/99-custom.conf"
    permissions = "0644"
  }
  transactional_update_custom_config = {
    content     = <<-EOT
REBOOT_METHOD=kured
EOT
    path        = "/etc/transactional-update.conf"
    permissions = "0644"
  }
}
