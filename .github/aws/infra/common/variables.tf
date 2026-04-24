

# ──────────────────────────────────────────────────────────────────────────────
# BLAZE SIGNATURE TAGS (v1.4.94)
# ──────────────────────────────────────────────────────────────────────────────
variable "stack_name" {
  type        = string
  default     = "dev-app"
  description = "Stack identifier for Blaze:Stack tag. Set automatically by CI."
}

variable "blaze_run_id" {
  type        = string
  default     = "manual"
  description = "GitHub Actions run ID for Blaze:RunId tag."
}
