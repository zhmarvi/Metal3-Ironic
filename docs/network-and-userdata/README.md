# Network and User-Data

## Cloud-Init Docuementation: 
https://cloudinit.readthedocs.io/en/latest/explanation/format.html#cloud-config-data

### Create a NetworkData Secret within the Cluster namespace​

Example of Creating a network-data-secret: 
```
kubectl -n <namespace> create secret generic <secret-name> --from-file=networkData=<path_to_network_json>​
```

## UserData Secret
```
kubectl -n <namespace> create secret generic <user-data-secret-name> --from-file=userData=<path_to_user-data_config>​
```
