# AWS RDS postgres Terraform Module

Terraform module which creates postgres resources


## Requirements

- Make sure kandula database is created with the a jenkinsfile saved in this [repo](https://github.com/GoddessDianaPub/kandula-app/tree/main/Jenkinsfiles)


## Notes

- There are 2 tables created within kandula schema, one for instances_scheduler and one for instances_shutdown_log
- You can schedule a shutdown hour for each instance according to the instances you have in your DB
- Ports 5432 is opened for postgresSql
- Ports are opened for 9300, 9200 5044 for ELK logging access
