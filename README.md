# Terraform Hetzner Cloud K3S

## 🎯 About

Get a cheap HA-ready Kubernetes cluster in less than **5 minutes**, with easy configuration setup through simple Terraform variables, 💯 GitOps way !

This opinionated Terraform template will generate a ready-to-go cloud infrastructure through Hetzner Cloud provider, optimized for [MicroOS](https://microos.opensuse.org/), with preinstalled [K3S](https://github.com/k3s-io/k3s), the most popular lightweight Kubernetes distribution.

Heavily inspired by [Kube-Hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner), but largely simplified by excluding all custom helm installs that I prefer to manage externally. It doesn't use any local/remote exec provisioners, only `cloud-init`, so quicker to set up, and `Powershell` compatible.

## 🚀 Quick start

A valid MicroOS snapshot, identified by the selector `microos-snapshot=yes` must be available in your Hetzner Cloud account. The latest snapshot will be automatically selected by default.

## 📝 License

This project is under license from MIT. For more details, see the [LICENSE](https://adr1enbe4udou1n.mit-license.org/) file.

Made with :heart: by <a href="https://github.com/adr1enbe4udou1n" target="_blank">Adrien Beaudouin</a>
