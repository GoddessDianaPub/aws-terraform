output "instance_bastion_id" {
   value = aws_instance.bastion.id
}

output "bastion_ssh_from_security_group_id" {
   value = aws_security_group.allow_ssh_from_bastion_sg.id
}

output "bastion_ssh_to_security_group_id" {
   value = aws_security_group.allow_ssh_to_bastion_sg.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "eip_bastion" {
   value = aws_eip.eip_bastion.public_ip
}

output "workstation-external-ip" {
   value = local.workstation-external-cidr
}


