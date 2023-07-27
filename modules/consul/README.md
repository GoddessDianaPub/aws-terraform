# AWS Consul Terraform Module

Terraform module which creates consul servers resources

## Requirements

- Open port 8500 for consul server UI
- Open ports 8300-8301 for the agents
- Tag the consul servers with this "key:value" pair:
    - Consul = "server"
- Tag the consul agents with this "key:value" pair:
    - Consul = "agent"


## Notes

- Consul servers will be installed using terraform
- Consul agents will be installed using ansible server
- There is an A record and alb configured for this subdomain: https://consul.dianatop.lat
- For more info please go to [ansible server repo](https://github.com/GoddessDianas/terraform-aws-all/tree/main/modules/ansible)
