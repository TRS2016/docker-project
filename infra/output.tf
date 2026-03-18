output "server_ip" {
  value       = aws_eip.web.public_ip
  description = "IP publique du serveur"
}