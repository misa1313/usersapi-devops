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

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

