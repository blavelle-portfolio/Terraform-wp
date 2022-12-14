resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "sudo echo \"${tls_private_key.main.private_key_pem}\" >> $PWD/private.pem"
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