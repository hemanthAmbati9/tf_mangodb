terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 1.0.0"
    }
  }
  required_version = ">= 1.2"
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key     # set via env or tfvars
  private_key = var.atlas_private_key    # set via env or tfvars
  # Optionally set: base_url = "https://cloud.mongodb.com/api/atlas/v1.0"
}