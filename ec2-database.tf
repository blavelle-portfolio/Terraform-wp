data "template_file" "phpconfig" {
  template = file("files/conf.wp-config.php")

  vars = {
    db_port = aws_db_instance.mysql.port
    db_host = aws_db_instance.mysql.address
    db_user = var.username
    db_pass = var.password
    db_name = var.db_name
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = var.db_name
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  skip_final_snapshot    = true
}

resource "aws_instance" "ec2" {
  ami           = var.ami
  instance_type = "t3.small"

  depends_on = [
    aws_db_instance.mysql,
  ]

  key_name                    = "wordpress-deploy-${random_pet.env.id}"
  vpc_security_group_ids      = [aws_security_group.web.id]
  subnet_id                   = aws_subnet.public1.id
  associate_public_ip_address = true

  user_data = file("files/userdata.sh")

  tags = {
    Name = "EC2 Instance"
  }

  provisioner "file" {
    source      = "files/userdata.sh"
    destination = "/tmp/userdata.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = tls_private_key.main.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/userdata.sh",
      "/tmp/userdata.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = tls_private_key.main.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.phpconfig.rendered
    destination = "/tmp/wp-config.php"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = tls_private_key.main.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/wp-config.php /var/www/html/wp-config.php",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = tls_private_key.main.private_key_pem
    }
  }

  timeouts {
    create = "20m"
  }
}
