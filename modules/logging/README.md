# AWS ELK Terraform Module

Terraform module which creates elasticsearch + filebeat + kibana resources

## Requirements

- Open ingress ports 5601, 9300, 9200, 5044 for ELK cluster
- Open ingress ports 8300-8301 for the agents

## Notes

- This is a self-managed elasticsearch cluster
- There is an A record and alb configured for this subdomain: https://kibana.dianatop.lat
