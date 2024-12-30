# Metal3-Ironic

Metal³ provides components for BareMetal host management with Kubernetes. You can enroll your BareMetal machines and provision operating system images. ​

This is paired with one of the components from the OpenStack ecosystem, Ironic for booting and installing machines. Metal³ handles the installation of Ironic as a standalone component​

## MAIN UPSTREAM DOCUMENTATION: 
https://book.metal3.io/​

## Metal3 abilities and components:​

- Discover your hardware inventory​
- Configure BIOS and RAID settings on your hosts​
- Optionally clean a host’s disks as part of provisioning​
- Install and boot an operating system image of your choice​


### Infrastructure Setup:​

- Provision Hardware and Network Fabric​
- Construct a Management Kubernetes Cluster​
- Deploy Supplementary Resources on Management Cluster​
- Deploy Metal3 Resources

### Installation
#### Preliminary Steps:​
- Deploy a DHCP Server pod​ LINK: https://github.com/zhmarvi/Metal3-Ironic/blob/main/docs/DHCP-Server_Deploy.md
- Deploy and setup a Disk-image Server​ LINK: https://github.com/zhmarvi/Metal3-Ironic/tree/main/docs/image-server

#### Installation Steps:​
- Deploy Metal3 Ironic​ (via Helm) LINK: https://github.com/zhmarvi/Metal3-Ironic/blob/main/docs/Metal3-Helm.md
