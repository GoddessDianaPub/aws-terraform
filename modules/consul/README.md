# AWS Consul Terraform Module

Terraform module which creates consul servers resources


## Notes

- Consul servers will be installed using terraform
- There is an A record and alb configured for this subdomain: https://consul.dianatop.lat
- For more info about the A record please go to [alb repo](https://github.com/GoddessDianaPub/aws-terraform/tree/main/modules/alb)
- The consul servers are tagged with this "key:value" pair:
    - Consul = "server"
- The consul agents are tagged with this "key:value" pair:
    - Consul = "agent"