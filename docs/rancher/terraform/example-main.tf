terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
      version = "5.1.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.34.0"
    }
  }
}

locals {

api_url = "https://<RANCHER_URL>/"
ca_certificates = <CA_CERT>


}

provider "kubernetes" {
  config_path = "<PATH_TO_KUBECONFIG>"
}


provider "rancher2" {
  api_url    = local.api_url  # Replace with your Rancher server URL
  access_key = "<ACCESS_TOKEN>"  # Replace with your Rancher API access key
  secret_key = "<SECRET_KEY>"  # Replace with your Rancher API secret key
  insecure   = true                     # Set to true if using self-signed certificates (optional)
}

resource "rancher2_cluster_v2" "cluster" {
  name = "CLUSTER_NAME>"
  kubernetes_version = "v1.30.6+rke2r1"
}

data "rancher2_cluster_v2" "cluster" {
  name = "<CLUSTER_NAME>"
  fleet_namespace = "fleet-default"
}

output "token" {
  value = rancher2_cluster_v2.cluster.cluster_registration_token.0.insecure_node_command
  sensitive = true
}


data "cloudinit_config" "config" {
  base64_encode = false
  gzip = false
  part {
    filename     = "ubuntu-init.tpl"
    content_type = "text/cloud-config"
    content = templatefile("ubuntu-init.tpl", {
      join_command : rancher2_cluster_v2.cluster.cluster_registration_token.0.insecure_node_command
      ca_certificates :  local.ca_certificates
      node_role : "--etcd --controlplane --worker"
    })
  }
}

output "user-data" {
  value = data.cloudinit_config.config.rendered
}

resource "local_file" "file" {
    content  = rancher2_cluster_v2.cluster.cluster_registration_token.0.node_command
    filename = "private_key.pem"
}

resource "kubernetes_secret" "user-data-secret" {
  metadata {
    name = <USER_DATA_SECRET>"
    namespace = "<METAL3_CLUSTER_NAMESPACE>"
  }
  type = "generic"
  data = {
    userData = data.cloudinit_config.config.rendered
  }
}

variable "ca_certificates" {
  type = string
  default = ""
}
