# Terraform Hetzner Cloud K3S

## 🎯 About

Get a cheap HA-ready Kubernetes cluster in less than **5 minutes**, with easy configuration setup through simple Terraform variables, 💯 GitOps way !

This opinionated Terraform template will generate a ready-to-go cloud infrastructure through Hetzner Cloud provider, optimized for [MicroOS](https://microos.opensuse.org/), with preinstalled [K3S](https://github.com/k3s-io/k3s), the most popular lightweight Kubernetes distribution.

Heavily inspired by [Kube-Hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner), but largely simplified by excluding all custom helm installs that I prefer to manage externally. It doesn't use any local/remote exec provisioners, only `cloud-init`, so quicker to set up, and `Powershell` compatible.

> For people that need a lightweight container orchestrator, the [Swarm provider](https://github.com/okami101/terraform-hcloud-swarm) should be a better fit.

## 🚀 Quick start

A valid MicroOS snapshot, identified by the selector `microos-snapshot=yes` must be available in your Hetzner Cloud account. The latest snapshot will be automatically selected by default.

## ✅ Requirements

Before starting, you need to have :

1. A Hetzner cloud account.
2. A `terraform` client.
3. A `hcloud` client.
4. A `kubectl` client.

On Windows :

```powershell
scoop install terraform hcloud
```

## 🏁 Starting

### Prepare

The first thing to do is to prepare a new hcloud project :

1. Create a new **EMPTY** hcloud empty project.
2. Generate a **Read/Write API token key** to this new project according to [this official doc](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/).

### Setup

Now it's time for initial cluster setup.

1. Copy [this kube config example](kube.tf.example) into a new empty directory and rename it `kube.tf`.
2. Execute `terraform init` in order to install the required module
3. Replace all variables according your own needs.
4. Finally, use `terraform apply` to check the plan and initiate the cluster setup.

## Topologies

Contrary to Docker Swarm which is very flexible at low prices, with many topologies possible [as explained here](https://github.com/okami101/terraform-hcloud-swarm#topologies), K8S is really thought out for HA and high horizontal scalability, with complex workloads.

### For administrators

```mermaid
flowchart TB
ssh((SSH))
kubectl((Kubectl))
kubectl -- Port 6443 --> lb{LB}
ssh -- Port 2222 --> controller-01
lb{LB}
subgraph controller-01
  direction TB
  kube-apiserver-01([Kube API Server])
  etcd-01[(ETCD)]
  kube-apiserver-01 --> etcd-01
end
subgraph controller-02
  direction TB
  kube-apiserver-02([Kube API Server])
  etcd-02[(ETCD)]
  kube-apiserver-02 --> etcd-02
end
subgraph controller-03
  direction TB
  kube-apiserver-03([Kube API Server])
  etcd-03[(ETCD)]
  kube-apiserver-03 --> etcd-03
end
lb -- Port 6443 --> controller-01
lb -- Port 6443 --> controller-02
lb -- Port 6443 --> controller-03
```

### For clients

```mermaid
flowchart TB
client((Client))
client -- Port 80 + 443 --> lb{LB}
lb{LB}
lb -- Port 80 --> worker-01
lb -- Port 80 --> worker-02
lb -- Port 80 --> worker-03
subgraph worker-01
  direction TB
  traefik-01{Traefik}
  app-01([My App replica 1])
  traefik-01 --> app-01
end
subgraph worker-02
  direction TB
  traefik-02{Traefik}
  app-02([My App replica 2])
  traefik-02 --> app-02
end
subgraph worker-03
  direction TB
  traefik-03{Traefik}
  app-03([My App replica 3])
  traefik-03 --> app-03
end
overlay(Overlay network)
worker-01 --> overlay
worker-02 --> overlay
worker-03 --> overlay
overlay --> db-rw
overlay --> db-ro
db-rw((RW SVC))
db-rw -- Port 5432 --> storage-01
db-ro((RO SVC))
db-ro -- Port 5432 --> storage-01
db-ro -- Port 5432 --> storage-02
subgraph storage-01
  pg-primary([PostgreSQL primary])
  longhorn-01[(Longhorn<br>volume)]
  pg-primary --> longhorn-01
end
subgraph storage-02
  pg-replica([PostgreSQL replica])
  longhorn-02[(Longhorn<br>volume)]
  pg-replica --> longhorn-02
end
db-streaming(Streaming replication)
storage-01 --> db-streaming
storage-02 --> db-streaming
```

## 📝 License

This project is under license from MIT. For more details, see the [LICENSE](https://adr1enbe4udou1n.mit-license.org/) file.

Made with :heart: by <a href="https://github.com/adr1enbe4udou1n" target="_blank">Adrien Beaudouin</a>
