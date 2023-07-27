# AWS OpenVPN Terraform Module

Terraform module which creates OpenVPN instance

## Notes

- This elastic IP has been reserved for this server: 3.210.152.77
- This server has a self signed certificate and will be unsecure when accessing the site (unless you will install this certificate on your computer as well).
- The server has been configured using AWS OpenVPN ami, but you can create your own using this [article](https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-ubuntu-22-04)
- There is ALB configured for this subdomain: openvpn.dianatop.lat as well as an A record in route53
- To access the admin UI: https://openvpn.dianatop.lat/admin
- To access the user UI: https://openvpn.dianatop.lat
- This server has 2 tags related to installing consul agent with ansible: OSType: openvpn and Consul: agent
- The agents are looking for the servers when they are joining consul with this tags: Consul: server
