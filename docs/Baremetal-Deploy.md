# Create a Baremetal Host

Now that we have Bare Metal Operator deployed, let’s put it to use by creating BareMetalHosts (BMHs) to represent our servers. You will need the protocol and IPs of the BMCs, as well as credentials for accessing them, and the servers MAC addresses.

Create one secret for each BareMetalHost, containing the credentials for accessing its BMC. No credentials are needed in the virtualized setup but you still need to create the secret with some values. Here is an example:

```
apiVersion: v1
data:
  password: <PASSWORD_REDACTED_BASE64>
  username: <USERNAME_REDACTED_BASE64>
kind: Secret
metadata:
  creationTimestamp: null
  name: <OOB_CREDENTIAL_SECRET_NAME>
  namespace: <WORKLOAD_CLUSTER_NAMESPACE>
```

Then continue by creating the BareMetalHost manifest. You can put it in the same file as the secret if you want. Just remember to separate the two resources with one line containing ---.

Here is an example of a BareMetalHost referencing the secret above with MAC address and BMC address matching our server 

```
---
apiVersion: metal3.io/v1alpha1
kind: BareMetalHost
metadata:
  name: <BAREMETAL_HOST_NAME>
  namespace: <WORKLOAD_CLUSTER_NAMESPACE>
  labels:
    cluster-role: control-plane
spec:
  bmc:
    address: "redfish://<OOB_IP>:443/redfish/v1/Systems/System.Embedded.1"
    # BMC credentials - a link to a secret:
    credentialsName: <OOB_CREDENTIAL_SECRET>
    disableCertificateVerification: true
  # MAC address the node boots from. Will eventually be optional for
  # Redfish, but it's better to provide it.
  bootMACAddress: <PXE_MACADDRESS>
  # The node will use UEFI for booting (the default).
  bootMode: UEFI
  # Bring it online for further actions
  online: true
  # The `deviceName` hint is not the most reliable, you can use
  # `serialNumber`, `model`, `minSizeGigabytes` and a few others instead.
  
  raid:
    hardwareRAIDVolumes:
    - name: host-os
      level: "1"
      controller: RAID.Slot.6-1
      physicalDisks:
      - Disk.Bay.0:Enclosure.Internal.0-1:RAID.Slot.6-1
      - Disk.Bay.1:Enclosure.Internal.0-1:RAID.Slot.6-1
  image:
        checksum: http://<IMAGE_SERVER_IP>:8080/SHA256SUMS
        checksumType: sha256
        format: raw
        url: http://<IMAGE_SERVER_IP>:8080/<IMAGE>

  userData:
    name: <USER_DATA_NAME>
  networkData:
    name: <NETWORK_DATA_NAME>
```

Apply these in the cluster with kubectl apply -f path/to/file.

You should now be able to see the BareMetalHost go through registering and inspecting phases before it finally becomes available. Check with kubectl get bmh -n <namespace>. The output should look similar to this:
