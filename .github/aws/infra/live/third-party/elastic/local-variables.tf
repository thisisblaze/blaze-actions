# Elastic Cloud API Key
variable "ec_api_key" {
  description = "Elastic Cloud API Key"
  type        = string
  sensitive   = true
}

# Elastic Cloud region mapping
variable "ec_region_map" {
  description = "Map AWS regions to Elastic Cloud regions"
  type        = map(string)
  default = {
    # Testing direct region ID (removing aws- prefix)
    "eu-west-1" = "eu-west-1"
    "us-east-1" = "us-east-1"
  }
}

# Elasticsearch sizing
variable "elasticsearch_size" {
  description = "Elasticsearch node size (e.g. 1g, 2g, 4g)"
  type        = string
  default     = "1g"
}

variable "elasticsearch_zone_count" {
  description = "Number of availability zones for Elasticsearch"
  type        = number
  default     = 1
}

# Kibana sizing
variable "kibana_size" {
  description = "K ibana instance size"
  type        = string
  default     = "1g"
}

variable "kibana_zone_count" {
  description = "Number of availability zones for Kibana"
  type        = number
  default     = 1
}
