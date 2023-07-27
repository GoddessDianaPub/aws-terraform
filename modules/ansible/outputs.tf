output "ansible_server_private_address" {
    value = aws_instance.ansible_server.*.private_ip
}

