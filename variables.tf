variable "project_id" {}
variable "region"    { default = "us-central1" }
variable "zone"      { default = "us-central1-a" }

variable "controller_name" { default = "openstack-controller" }
variable "compute_name"    { default = "openstack-compute" }

variable "machine_type" { default = "e2-micro" }

variable "gcp_credentials_file" {}

variable "ssh_user"     { default = "ubuntu" }
variable "ssh_pub_path" { default = "../.ssh/id_openstack.pub" }