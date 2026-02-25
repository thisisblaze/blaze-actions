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
