# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "ssh-key" {
  key_name   = "ec2-key-pair"  
  public_key = tls_private_key.ssh-key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  content  = tls_private_key.ssh-key.private_key_pem
  filename = "${aws_key_pair.ssh-key.key_name}.pem"
  }