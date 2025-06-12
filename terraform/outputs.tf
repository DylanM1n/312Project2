output "public_ip" {
  value       = aws_eip.mc_ip.public_ip
  description = "Minecraft server address"
}
