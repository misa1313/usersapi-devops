output "vm_ip" {
  value = aws_eip.interface_eip.public_ip
}

resource "local_file" "ansible_inventory" {
  filename        = "../ansible/inventory"
  file_permission = "0644"
  content         = <<EOT
[jenkins]
${aws_eip.interface_eip.public_ip} ansible_ssh_retries=10 ansible_ssh_timeout=30

[jenkins:vars]
ansible_user = "ubuntu"
ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_ssh_private_key_file="${var.ssh_key_file}"
EOT
}

