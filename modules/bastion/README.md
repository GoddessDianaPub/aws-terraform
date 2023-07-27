# AWS Bastion Terraform Module

Terraform module which creates bastion resources.

## Notes

- In order to seperate the ssh connections, there are 2 security groups:
  -  opsschhol-project-allow-ssh-to-bastion-sg: this SG allows connections to the bastion itself
  -  opsschhol-project-allow-ssh-from-bastion-sg - this SG is configured in all the instances in order to the bastion to ssh them
- The OpenVPN elastic IP is also configured in this SG: opsschhol-project-allow-ssh-from-bastion-sg
- This server has 2 tags related to installing consul agent eith ansible: OSType: amazon and Consul: agent
- The agents are looking for the consul servers when they are joining consul cluster with this tags: Consul: server
