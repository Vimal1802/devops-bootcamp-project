# 1. We NO LONGER need tls_private_key or local_file for the .pem

# 2. Pack the Ansible folder
# This will now only contain your playbooks, roles, and config files
data "archive_file" "ansible_pack" {
  type        = "zip"
  source_dir  = "${path.module}/../ansible"
  output_path = "${path.module}/ansible_pack.zip"

  # Removed: depends_on = [local_file.private_key_pem]
}

# 3. Encode the zip for the User Data
locals {
  ansible_zip_data = (data.archive_file.ansible_pack.output_base64sha256 != "") ? filebase64(data.archive_file.ansible_pack.output_path) : ""
}