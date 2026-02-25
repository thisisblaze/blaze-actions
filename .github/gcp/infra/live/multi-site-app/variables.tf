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

# ── Sites Map ──

variable "sites" {
  description = "Map of site_key => site configuration."
  type = map(object({
    domain          = string
    image           = optional(string, "us-docker.pkg.dev/cloudrun/container/hello")
    cpu             = optional(string, "1")
    memory          = optional(string, "512Mi")
    container_port  = optional(number, 8080)
    min_instances   = optional(number, 0)
    max_instances   = optional(number, 5)
    concurrency     = optional(number, 80)
    cpu_idle        = optional(bool, true)
    health_path     = optional(string, "/health")
    env_vars        = optional(map(string), {})
    enable_cdn      = optional(bool, true)
    security_policy = optional(string, "")
  }))
  default = {}
}

# ── Cloudflare ──

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}
variable "cloudflare_account_id" {
  type = string
}
variable "cloudflare_zone_id" {
  type = string
}
