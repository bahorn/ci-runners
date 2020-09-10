variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

variable "worker_count" {
  default = 1
}

variable "region" {
  default = "ams3"
}

# DOs unique key ID, mostly to supress emails container a password.
variable "ssh_key_id" {}
# Copy of our key, which will get passed to cloud-id
variable "ssh_public_key" {}
# GitLab instance to connect to.
variable "gl_instance" {}
variable "gl_registration_token" {}

data "template_file" "cloud-init-yaml" {
  template = file("${path.module}/cloud-init.yaml")
  vars = {
    init_ssh_public_key = var.ssh_public_key
    gl_instance = var.gl_instance
    gl_registration_token = var.gl_registration_token
  }
}

resource "digitalocean_droplet" "ci-runner" {
  name = "gitlab-runner-${var.worker_count}"
  count = var.worker_count
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-20-04-x64"
  region = var.region
  user_data = data.template_file.cloud-init-yaml.rendered
  ssh_keys = [var.ssh_key_id]
}

output "ip" {
  value = digitalocean_droplet.ci-runner.*.ipv4_address
}
