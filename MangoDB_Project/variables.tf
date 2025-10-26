variable "atlas_public_key" {
  type        = string
  description = "Atlas API public key (from Atlas UI). Prefer to pass via env or tfvars."
  #sensitive   = true
  default     = "mcqncxej"
}

variable "atlas_private_key" {
  type        = string
  description = "Atlas API private key (from Atlas UI). Prefer to pass via env or tfvars."
  #sensitive   = true
  default     = "b396c544-6973-467c-8c12-52e3be4c0de2"
}

variable "org_id" {
  type        = string
  description = "MongoDB Atlas Organization ID (required)."
  default     = "68fe925161c6781a5774802d"
}

variable "project_name" {
  type        = string
  default     = "tf-mongo-project"
}

variable "cluster_name" {
  type        = string
  default     = "tf-m0-mlops-cluster"
}

variable "cluster_region" {
  type        = string
  default     = "US_EAST_1" # change to an M0-supported region for your provider (Atlas lists supported M0 regions)
}

variable "db_username" {
  type        = string
  default     = "tf_user"
}

variable "db_password" {
  type        = string
  description = "Password for the MongoDB user. Pass via env/secret manager or terraform.tfvars (sensitive)."
  #sensitive   = true
  default     = "TfUser@1234"
}