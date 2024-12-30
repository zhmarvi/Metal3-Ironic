# Deploy image Server
In order for ironic to provision baremetal nodes, we will need either an public accessible repo or an internal based repo accessible by the Metal3 provider in order to push and install the raw image to the BareMetal machine. Below is an example manifest we used for our Demo but this can be done completely different method. Please note any images uploaded to a server will need a file to include the sha256sum hash within a separately called file '<PATH/SHA256SUMS>'

Upstream Metal3 Documentation: https://book.metal3.io/quick-start#image-server

## INSTALL
```
cd <image_server_deployment_directory>
kubectl apply -k .
```
## POST INSTALL

Once provisioned you will be able to see the image server has a LoadBalancer Resource which can be CURL'd pulled from

### UPLOAD AN IMAGE from a local (using kubectl cp)
```
kubectl cp -n <namespace> <source path to image> <pod_name>:/usr/share/nginx/html/
```
