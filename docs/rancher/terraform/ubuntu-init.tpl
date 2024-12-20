%{if ca_certificates != ""~}
ca-certs:
  trusted:
  - |
   ${indent(3, ca_certificates)}
%{endif~}
users:
- name: ubuntu
  sudo: ["ALL=(ALL) NOPASSWD:ALL"]
  ssh_authorized_keys:
    - <INJECTABLE_PUBLIC_SSH_KEY>

runcmd:
 - ${join_command} ${node_role}
