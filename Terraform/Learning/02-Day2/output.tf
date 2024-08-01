output "PrivateKey" {
    value = tls_private_key.privateKey.private_key_pem
    sensitive = false
}

output "public_IP_Address" {
    value = azurerm_public_ip.publicIP-01.ip_address
}