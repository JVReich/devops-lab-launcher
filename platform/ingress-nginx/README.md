# Ingress NGINX

This platform component deploys the NGINX Ingress Controller to AKS.

## Purpose

The ingress controller exposes selected lab stacks through HTTP/HTTPS routes.

Later this will be used with:

- DNS records
- cert-manager
- Let's Encrypt certificates
- stack-specific subdomains

## Helm Chart

```text
ingress-nginx/ingress-nginx