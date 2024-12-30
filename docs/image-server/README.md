# Deploy image Server
In order for ironic to provision baremetal nodes, we will need either an public accessible repo or an internal based repo accessible by the Metal3 provider in order to push and install the raw image to the BareMetal machine. Below is an example manifest we used for our Demo but this can be done completely different method. Please note any images uploaded to a server will need a file to include the sha256sum hash within a separately called file '<PATH/SHA256SUMS>'

Upstream Metal3 Documentation: https://book.metal3.io/quick-start#image-server

## INSTALL
```
cd <path>/Metal3-Ironic/docs/image-server
kubectl apply -k .
```
## POST INSTALL

Once provisioned you will be able to see the image server has a LoadBalancer Resource as the main endpoint.

## UPLOAD IMAGES
NOTE: This can be done i other ways, that are probably more efficient but this will be a base example

Create a image directory
```
mkdir disk-images
```

```
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
wget https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS
sha256sum --ignore-missing -c SHA256SUMS
```
NOTE: FOR RAW IMAGES YOU WILL NEED TO CONVERT A QCOW2 OR PULL A CUSTOM IMAGE AND THEN GET THE 256SHA and add it to the SHA256SUMS file


### PUSH IMAGE TO NGINX CONTAINER from local directory (using kubectl cp)
```
kubectl cp -n <namespace> <source path to image> <pod_name>:/usr/share/nginx/html/
```
