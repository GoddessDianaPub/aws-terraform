output "rds_subnet_group_id" {
   value = aws_db_subnet_group.rds_sg.*.id
}

output "rds_instance_id" {
   value = aws_db_instance.rds.*.id
}

output "rds_private_endpoint" {
  value = try(aws_db_instance.rds.*.endpoint, "")
}
