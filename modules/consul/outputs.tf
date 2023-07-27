output "consul_servers_private_ip" {
  value = aws_instance.consul_server.*.private_ip
}

output "consul_server_instance_id" {
   value = aws_instance.consul_server.*.id
}