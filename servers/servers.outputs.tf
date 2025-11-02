output "webserver_sg_id" {
    value = aws_security_group.web_sg.id
}   

output "web_server_ip" {
  value = aws_eip.web_ip.public_ip
}