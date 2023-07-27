output "jenkins_agent_private_ip" {
  value = aws_instance.jenkins_agent.*.private_ip
}

output "jenkins_server_private_ip" {
  value = aws_instance.jenkins_server.*.private_ip
}

output "jenkins_server_instance_id" {
   value = aws_instance.jenkins_server.*.id
}

output "jenkins_agent_instance_id" {
   value = aws_instance.jenkins_agent.*.id
}