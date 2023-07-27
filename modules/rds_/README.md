# AWS RDS postgres Terraform Module

Terraform module which creates postgres resources


## Requirements

- Open port 5432 for postgresSql
- Open ports 9300, 9200 5044 for ELK logging access
- Make sure kandula database is created with the a jenkinsfile saved in this [repo](https://github.com/GoddessDianas/kandula-app/tree/main/Jenkinsfiles)


## Notes

- There are 2 tables created within kandula schema, one for instances_scheduler and one for instances_shutdown_log
- Kandula app will take the instances data from the instances_scheduler table, and will create scheduling according the data in that table.
