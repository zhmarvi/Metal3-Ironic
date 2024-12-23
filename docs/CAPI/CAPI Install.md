# Install CAPI

## Run the command to create a initial cluster with the Metal3 provider
```
clusterctl init --core "cluster-api:v1.8.5" --infrastructure "metal3:v1.8.3" --bootstrap "rke2:v0.9.0" --control-plane "rke2:v0.9.0"
```
