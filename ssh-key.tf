resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.main.private_key_pem}\" > private.pem"
  }

  provisioner "local-exec" {
    command = "chmod 400 private.pem"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "wordpress-deploy-${random_pet.env.id}"
  public_key = tls_private_key.main.public_key_openssh
}

resource "random_pet" "env" {
  length    = 2
  separator = "-"
}