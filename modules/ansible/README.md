# AWS Ansible Terraform Module

Terraform module which creates ansible server resources

## Requirements

- Add the ssh private key to ansible server, in order to manage the other instances via ssh
- Open port 22 to access all the instances in your VPC
- Tag the instances you want to install the roles on:
  - consul service with tags: Consul: agent
  - filebeat service with tags: Logging: filebeat
  - node_exporter service with tags: Monitoring: node_exporter
- Install a role on instances:
    - Run this command to make sure you see all the instances you need to see:
        - ansible-inventory --graph -i (inventory-file-name)
    - Run this command to install consul:
        - ansible-playbook -i (inventory-file-name) (playbook-file-name)
- Add these roles to your ansible server:
  - ansible-galaxy install buluma.java
  - ansible-galaxy install buluma.elasticsearch
  - ansible-galaxy install buluma.filebeat
  - ansible-galaxy install buluma.consul
- Create the node_exporter role with this [article](https://blog.devops4me.com/install-grafana-prometheus-node_exporter-using-ansible/)

## Notes

- Consul agents will be installed using ansible server:
  - The playbook as well as the dynamic inventory file, are configured and saved in ansible server in this path: ~/ansible (and in here as well: modules/ansible/ansible_files).
  - The users to ssh with are configured in this path: ~/ansible/group_vars
  - The agents are looking for the servers when they are joining consul with this tags: Consul: server
- Monitoring: node exporter is going to be installed using ansible:
  - The playbook as well as the dynamic inventory file, are configured and saved in ansible server in this path: ~/ansible
  - The users to ssh with are configured in this path: ~/ansible/group_vars
  - The instances that the node_eporter is going to be installed on, are configured with this tag: Monitoring: node_exporter
- Logging: filebeat is going to be installed using ansible:
  - The playbook as well as the dynamic inventory file, are configured and saved in ansible server in this path: ~/ansible
  - The users to ssh with are configured in this path: ~/ansible/group_vars
  - The instances that the node_eporter is going to be installed on, are configured with this tag: Logging: filebeat
