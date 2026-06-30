# Architecture

## Overview

AKS DevOps Lab Launcher is an ephemeral Azure/Kubernetes lab platform.

The platform is designed to create a low-cost AKS environment and deploy selected DevOps/Kubernetes stacks on demand.

## High-Level Flow

```text
GitHub Repository
        |
        v
Azure Pipelines
        |
        v
Terraform
        |
        v
Azure Infrastructure
        |
        v
AKS Cluster
        |
        v
Helm Platform Components
        |
        v
Selected Lab Stack