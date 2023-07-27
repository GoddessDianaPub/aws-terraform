# AWS VPC Terraform Module

Terraform module which creates VPC resources


## Notes

- There are public subnets and private subnets configured
- All the resources will be created in the private subnets, execpt OpenVPN, bastion and ALB that will be created in the public subnets
- There are EKS tags on subnets and VPC, in order to interact with EKS.
