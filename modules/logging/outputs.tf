
output "logging_private_ip" {
  value = aws_instance.logging.*.private_ip
}

output "logging_sg" {
  value = aws_security_group.logging_sg.id
}


output "logging_instance_id" {
   value = aws_instance.logging.*.id
}