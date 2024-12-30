# Deploy Ironic container for metal3

## NOTE: This is the process for manual installation using kustomize to deploy metal3-ironic. please use the other Metal3-Helm doc for helm based deploy from SUSE edge.

## DOCUMENTATION LINK: https://book.metal3.io/quick-start

We will be using kustomize for this process

```
mkdir <DIRECTORY>/ironic
```

## Authentication configuration
Create authentication configuration for Ironic and Inspector. You will need to generate a username and password for each. We will here refer to them as IRONIC_USERNAME, IRONIC_PASSWORD, INSPECTOR_USERNAME and INSPECTOR_PASSWORD.
Create a file ironic-auth-config with configuration for how to access Ironic. This will be use by Inspector. It should have the following content:
```
[ironic]
auth_type=http_basic
username=IRONIC_USERNAME
password=IRONIC_PASSWORD
```
Create a file ironic-inspector-auth-config with configuration for how to access Inspector. This will be used by Ironic. It should have the following content:
```
[inspector]
auth_type=http_basic
username=INSPECTOR_USERNAME
password=INSPECTOR_PASSWORD
```
To enable basic auth, we need to create secrets containing the keys IRONIC_HTPASSWD and INSPECTOR_HTPASSWD with values generated from the credentials using htpasswd. We will do this by creating two files ironic-htpasswd and ironic-inspector-htpasswd with the following content.

ironic-htpasswd:
```
IRONIC_HTPASSWD="<output of `htpasswd -n -b -B IRONIC_USERNAME IRONIC_PASSWORD`>"
```
Similarly for ironic-inspector-htpasswd:
```
INSPECTOR_HTPASSWD="<output of `htpasswd -n -b -B INSPECTOR_USERNAME INSPECTOR_PASSWORD`>"
```
## Ironic environment variables
In this section we will create a file containing environment variables used to configure Ironic and related components. We will call the file ironic_bmo.env. It looks like this for the baremetal lab:
```
# Same port as exposed in kind.yaml
HTTP_PORT=6180
# This is the interface inside the container
PROVISIONING_INTERFACE=eth0
# URL where the http server is exposed (IP of management computer)
CACHEURL=http://192.168.0.150
IRONIC_KERNEL_PARAMS=console=ttyS0
# IP where the BMCs can access Ironic to get the virtualmedia boot image.
# This is the IP of the management computer in the out of band network.
IRONIC_EXTERNAL_IP=192.168.1.7
# URLs where the servers can callback during inspection.
# IP of management computer in the other network and same ports as in kind.yaml
IRONIC_EXTERNAL_CALLBACK_URL=https://192.168.0.150:6385
IRONIC_INSPECTOR_CALLBACK_ENDPOINT_OVERRIDE=https://192.168.0.150:5050
```
For the virtualized environment it looks like this:
```
HTTP_PORT=6180
PROVISIONING_INTERFACE=eth0
CACHEURL=http://192.168.222.1/images
IRONIC_KERNEL_PARAMS=console=ttyS0
```
## Patch Ironic Deployment
The Ironic kustomization that we build on includes a dnsmasq container used for DHCP and PXE booting. However, we already set this up separately, because it is tricky to expose a DHCP server running inside kind. This means that we do not need the dnsmasq container that comes with the kustomization by default.

We will create a patch for removing it. It looks like this:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ironic
spec:
  template:
    spec:
      containers:
      - name: ironic-dnsmasq
        $patch: delete
```
Save it as ironic-patch.yaml.

## Ironic Kustomize
Time to tie it all together by creating a kustomization.yaml. At this point you should have a file structure like this:
```
ironic/
├── ironic-auth-config
├── ironic-htpasswd
├── ironic-inspector-auth-config
├── ironic-inspector-htpasswd
├── ironic-patch.yaml
├── ironic_bmo.env
└── kustomization.yaml
```
Here is a commented kustomization.yaml. Check carefully the IP addresses as these will always differ depending on environment.
```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: baremetal-operator-system
# These are the kustomizations we build on. You can download them and change the URLs to relative
# paths if you do not want to access them over the network.
# Note that the ref=v0.5.1 specifies the version to use.
resources:
- https://github.com/metal3-io/baremetal-operator/config/namespace?ref=v0.5.1
- https://github.com/metal3-io/baremetal-operator/ironic-deployment/base?ref=v0.5.1
# The kustomize components configure basic-auth and TLS
components:
- https://github.com/metal3-io/baremetal-operator/ironic-deployment/components/basic-auth?ref=v0.5.1
- https://github.com/metal3-io/baremetal-operator/ironic-deployment/components/tls?ref=v0.5.1
images:
- name: quay.io/metal3-io/ironic
  newTag: v24.0.0
# Create a ConfigMap from ironic_bmo.env and call it ironic-bmo-configmap.
# This ConfigMap will be used to set environment variables for the containers.
configMapGenerator:
- envs:
  - ironic_bmo.env
  name: ironic-bmo-configmap
  behavior: create

patches:
# Patch for removing dnsmasq
- path: ironic-patch.yaml
# The TLS component adds certificates but it cannot know the exact IPs of our environment.
# Here we patch the certificates to have the correct IPs.
# - 192.168.1.7: management computer IP in out of band network
# - 172.18.0.2: kind cluster node IP. This is what Ironic will see attached to the interface
#   and use to communicate with Inspector.
# - 192.168.0.150: management computer IP in the other network
- patch: |-
    - op: replace
      path: /spec/ipAddresses/0
      value: 192.168.1.7
    - op: add
      path: /spec/ipAddresses/-
      value: 172.18.0.2
    - op: add
      path: /spec/ipAddresses/-
      value: 192.168.0.150
  # The same patch in the virtualized environment looks like this:
  # - op: replace
  #   path: /spec/ipAddresses/0
  #   value: 192.168.222.1
  # - op: add
  #   path: /spec/ipAddresses/-
  #   value: 172.18.0.2
  target:
    kind: Certificate
    name: ironic-cert|ironic-inspector-cert
# The CA certificate should not have any IP address so we remove it.
- patch: |-
    - op: remove
      path: /spec/ipAddresses
  target:
    kind: Certificate
    name: ironic-cacert
# Create secrets from the authentication configuration.
# These will be mounted or used for environment variables.
# See the basic-auth component for more details on how they are used.
secretGenerator:
- name: ironic-htpasswd
  behavior: create
  envs:
  - ironic-htpasswd
- name: ironic-inspector-htpasswd
  behavior: create
  envs:
  - ironic-inspector-htpasswd
- name: ironic-auth-config
  files:
  - auth-config=ironic-auth-config
- name: ironic-inspector-auth-config
  files:
  - auth-config=ironic-inspector-auth-config
```
You can check that it works and inspect the resulting manifest by running this:
```
kubectl create -k ironic --dry-run=client -o yaml
```
When you are happy with the output, apply it in the cluster:
```
kubectl apply -k ironic
```

## Deploy BareMetal Operator
Similar to Ironic, we will create a kustomization for deploying Baremetal Operator. It will include credentials for accessing Ironic. Start with creating a folder for the kustomization:
```
mkdir bmo
```
Create files containing the credentials for Ironic and Inspector:

ironic-username
ironic-password
ironic-inspector-username
ironic-inspector-password
We will use kustomize to create secrets from these that Bare Metal Operator can use to access Ironic.

Next, create a file for environment variables. We will call it ironic.env. The content looks like this for the baremetal lab:

```
DEPLOY_KERNEL_URL=http://192.168.0.150:6180/images/ironic-python-agent.kernel
DEPLOY_RAMDISK_URL=http://192.168.0.150:6180/images/ironic-python-agent.initramfs
IRONIC_ENDPOINT=https://192.168.0.150:6385/v1/
```

The IP address is that of the management computer. The same in the virtualized environment looks like this:
```
DEPLOY_KERNEL_URL=http://192.168.222.1:6180/images/ironic-python-agent.kernel
DEPLOY_RAMDISK_URL=http://192.168.222.1:6180/images/ironic-python-agent.initramfs
IRONIC_ENDPOINT=https://192.168.222.1:6385/v1/
```
Finally, create the kustomization.yaml with this content:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: baremetal-operator-system
# This is the kustomization that we build on. You can download it and change
# the URL to a relative path if you do not want to access it over the network.
# Note that the ref=v0.5.1 specifies the version to use.
resources:
- https://github.com/metal3-io/baremetal-operator/config/overlays/basic-auth_tls?ref=v0.5.1
images:
- name: quay.io/metal3-io/baremetal-operator
  newTag: v0.5.1
# Create a ConfigMap from ironic.env and name it ironic.
configMapGenerator:
- name: ironic
  behavior: create
  envs:
  - ironic.env

# We cannot use suffix hashes since the kustomizations we build on
# cannot be aware of what suffixes we add.
generatorOptions:
  disableNameSuffixHash: true
# Create secrets with the credentials for accessing Ironic.
secretGenerator:
- name: ironic-credentials
  files:
  - username=ironic-username
  - password=ironic-password
- name: ironic-inspector-credentials
  files:
  - username=ironic-inspector-username
  - password=ironic-inspector-password

```
At this point, you should have a folder structure like this:
```
bmo/
├── ironic-password
├── ironic-username
├── ironic-inspector-username
├── ironic-inspector-password
├── ironic.env
└── kustomization.yaml
```
You can check that the kustomization works and inspect the resulting manifest by running this:
```
kubectl create -k bmo --dry-run=client -o yaml
```
When you are happy with the output, apply it in the cluster:
```
kubectl apply -k bmo
```
