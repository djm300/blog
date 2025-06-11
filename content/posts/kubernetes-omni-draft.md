---
title: 'Kubernetes Omni'
date: 2025-06-11T16:02:46+02:00
draft: true
---
# Deploying Sidero Omni on a Vanilla Kubernetes Cluster 🌐🚀📦

[Sidero Omni](https://omni.siderolabs.com) is a powerful control plane for provisioning and managing Talos Linux machines and Kubernetes clusters. In this guide, we'll walk through deploying Sidero Omni on a vanilla Kubernetes cluster, with practical examples for each step. ⚙️📘✨

---

## Prerequisites 🛠️📋🔧

Before you begin, ensure the following: 🧠✅📡

- You have access to a **vanilla Kubernetes cluster** (v1.25+).
- `kubectl` is configured to access the cluster.
- Helm is installed (v3+).
- You have basic knowledge of Kubernetes and Talos Linux.

---

## Step 1: Add the Sidero Labs Helm Repository 🧭📦📥

```bash
helm repo add siderolabs https://siderolabs.github.io/omni/helm-charts/
helm repo update
```

---

## Step 2: Create a Namespace for Omni 🗂️🚀📛

```bash
kubectl create namespace omni-system
```

---

## Step 3: Install Sidero Omni with Helm 🎛️🔧📦

The easiest way to deploy Omni is with Helm: 🧩💡🖥️

```bash
helm install omni siderolabs/omni \
  --namespace omni-system \
  --create-namespace
```

You can customize the installation using a `values.yaml` file. For example: 📝⚙️🔍

```yaml
# values.yaml
omni:
  ingress:
    enabled: true
    host: omni.example.com
```

Then install with: 🚀📁🔧

```bash
helm install omni siderolabs/omni \
  --namespace omni-system \
  --values values.yaml
```

---

## Step 4: Verify the Deployment 🔎🟢📊

Ensure all pods are running: 🖥️✅📋

```bash
kubectl get pods -n omni-system
```

Expected output: 📄📈📦

```bash
NAME                                      READY   STATUS    RESTARTS   AGE
omni-controller-...                       1/1     Running   0          1m
...
```

---

## Step 5: Access the Omni UI 🌐🔐🖥️

If you enabled ingress, open `https://omni.example.com` in your browser. 🌍🧭🖱️

If not using ingress, you can port-forward to access the UI: 🔁📲📡

```bash
kubectl port-forward svc/omni 8080:80 -n omni-system
```

Then navigate to [http://localhost:8080](http://localhost:8080). 🧪💻🔓

---

## Step 6: Add Talos Machines 🧬🖧🧩

Use the Omni web UI or CLI to register Talos machines. You will need to configure the Talos machines to PXE boot and point to Omni as their discovery endpoint. 🧭🚀🔧

Example Talos config snippet: 📑⚙️🔌

```yaml
machine:
  registration:
    endpoint: https://omni.example.com
```

---

## Step 7: Provision Kubernetes Clusters 🧱📦📈

Once machines are registered and approved in the Omni UI, you can create Kubernetes clusters via the UI or API. Omni will handle Talos configuration and cluster bootstrap. ⚙️🤖📡

---

## Conclusion 🎉📘🔚

Sidero Omni simplifies provisioning and lifecycle management of Talos Linux and Kubernetes clusters. Deploying it on a vanilla Kubernetes cluster is straightforward with Helm and requires only a few commands. 🛠️🧩✅

For more details, visit the [official documentation](https://omni.siderolabs.com/docs/). 🔗📚🧠

---

Happy provisioning! 🚀✨🔧

