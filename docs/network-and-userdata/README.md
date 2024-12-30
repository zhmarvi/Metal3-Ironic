# Network and User-Data

## Create a NetworkData Secret within the Cluster namespace​

Example: 
```
kubectl -n <namespace> create secret generic <secret-name> --from-file=networkData=<path_to_network_json>​
```
