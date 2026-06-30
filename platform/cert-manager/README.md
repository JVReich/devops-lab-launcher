# cert-manager

This platform component deploys cert-manager to AKS.

## Purpose

cert-manager will be used to issue TLS certificates for lab stack subdomains.

Planned usage:

- Let's Encrypt ClusterIssuer
- TLS certificates for stack ingress routes
- HTTPS access to exposed services

## Helm Chart

```text
jetstack/cert-manager