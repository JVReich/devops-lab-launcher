# NGINX Stack

This stack deploys a minimal NGINX instance to AKS using Helm.

## Purpose

This is the first validation stack for the AKS DevOps Lab Launcher.

It proves:

- AKS is reachable
- Helm can deploy workloads
- Kubernetes services are created correctly
- Later: ingress and DNS can expose the service

## Helm Chart

Planned chart:

```text
bitnami/nginx