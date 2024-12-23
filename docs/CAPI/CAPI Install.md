# Install CAPI


To install ClusterAPI with Metal3 (which uses Bare Metal hosts to create Kubernetes clusters), you need to follow several steps to set up the environment, install the necessary tools, and then deploy a cluster using ClusterAPI and Metal3.

Prerequisites:
- Linux machine (either VM or physical machine) for the management cluster.
kubectl installed and configured to access a Kubernetes cluster (for the management cluster).
- Working Kubernetes Cluster (can be on any cloud or on-prem).

Metal3 requirements:
- Supported version of Kubernetes (ClusterAPI and Metal3 are version-sensitive, check compatibility).

2. Install ClusterAPI and Metal3 CLI tools
Install ClusterAPI (CAPI) CLI: ClusterAPI has its own command-line interface (clusterctl) to interact with the Cluster API provider.

Download the latest release from GitHub:

```
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.8.5/clusterctl-linux-amd64 -o /usr/local/bin/clusterctl
chmod +x /usr/local/bin/clusterctl

```

Verify installation:
```
clusterctl version
```

## Run the command to create a initial cluster with the Metal3 provider
```
clusterctl init --core "cluster-api:v1.8.5" --infrastructure "metal3:v1.8.3" --bootstrap "rke2:v0.9.0" --control-plane "rke2:v0.9.0"
```
