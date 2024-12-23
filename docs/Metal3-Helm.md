# Install Metal3 via Helm

Documentation:
https://documentation.suse.com/suse-edge/3.0/html/edge/quickstart-metal3.html

## Pre-Reqs:

If not already installed as part of the Rancher installation, cert-manager must be installed and running.

MetalLB or another LoadBalancer service provider is required, this example we will install MetalLB

```
helm install \
  metallb oci://registry.suse.com/edge/metallb-chart \
  --namespace metallb-system \
  --create-namespace
```

Create the IPAddressPool and L2Advertisement Resource

IPAddressPool
```
export STATIC_IRONIC_IP=<STATIC_IRONIC_IP>

cat <<-EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ironic-ip-pool
  namespace: metallb-system
spec:
  addresses:
  - ${STATIC_IRONIC_IP}/32
  serviceAllocation:
    priority: 100
    serviceSelectors:
    - matchExpressions:
      - {key: app.kubernetes.io/name, operator: In, values: [metal3-ironic]}
EOF
```
L2 Advertisment
```
cat <<-EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: ironic-ip-pool-l2-adv
  namespace: metallb-system
spec:
  ipAddressPools:
  - ironic-ip-pool
EOF
```

## Metal3 Installation

Via Helm install the Metal3 Service

```
helm install \
  metal3 oci://registry.suse.com/edge/metal3-chart \
  --namespace metal3-system \
  --create-namespace \
  --set global.ironicIP="${STATIC_IRONIC_IP}"
```
NOTE: The metal3 pods/containers will take a few minutes to provision, you can watch the status of the containers

DO NOT PROCEED UNTIL CONTAINERS ARE IN READY STATE!

```
kubectl get pods -n metal3-system -w
```
