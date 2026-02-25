# ── Context ──

variable "namespace" {
  type = string
}
variable "client_key" {
  type = string
}
variable "project_key" {
  type = string
}
variable "stage" {
  type = string
}

variable "gcp_project_id" {
  type = string
}
variable "gcp_region" {
  type    = string
  default = "europe-west1"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.20.0.0/22"
}
variable "public_subnet_cidr" {
  type    = string
  default = "10.20.4.0/24"
}
variable "pods_cidr" {
  type    = string
  default = "10.100.0.0/16"
}
variable "services_cidr" {
  type    = string
  default = "10.101.0.0/16"
}
