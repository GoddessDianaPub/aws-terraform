output "instance_openvpn_id" {
   value = aws_instance.openvpn.id
}

output "openvpn_public_ip" {
  value = aws_instance.openvpn.public_ip
}

output "openvpn_private_ip" {
  value = aws_instance.openvpn.private_ip
}

output "eip_openvpn" {
   value = aws_eip_association.openvpn.public_ip
}



