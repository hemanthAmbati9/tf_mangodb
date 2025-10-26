# Create an Atlas Project inside the existing Organization
resource "mongodbatlas_project" "project" {
  org_id = var.org_id
  name   = var.project_name
}

# Create the free tier M0 cluster
# NOTE: M0 clusters have limitations (one M0 per project, limited config) — Atlas will list available regions for M0.
resource "mongodbatlas_cluster" "m0" {
  project_id = mongodbatlas_project.project.id
  name       = var.cluster_name

  # Use the "M0" provider settings for shared/free tier
  provider_name = "AWS"  # or "GCP" or "AZURE" — choose a provider that supports M0 in the region
  provider_instance_size_name = "M0"
  provider_region_name = var.cluster_region

  # Free tier constraints: many fields are ignored for M0; this minimal config requests M0.
  cluster_type = "REPLICASET"
  replication_specs {
    num_shards = 1
    region_configs {
      region_name               = var.cluster_region
      electable_specs {
        instance_size = "M0"
      }
      analytics_specs {
        instance_size = "M0"
      }
      read_only_specs {
        instance_size = "M0"
      }
    }
  }

  # optional: set backups, etc. Not supported for M0 or limited.
  lifecycle {
    create_before_destroy = false
  }
}

# Create a database user for the new cluster
resource "mongodbatlas_database_user" "db_user" {
  project_id = mongodbatlas_project.project.id
  username   = var.db_username
  password   = var.db_password
  roles {
    role_name     = "readWrite"
    database_name = "admin"
  }
  auth_database_name = "admin"
  mechanisms         = ["SCRAM-SHA-1", "SCRAM-SHA-256"]
}

# Data source (retrieve computed connection strings once cluster exists)
data "mongodbatlas_cluster" "cluster_info" {
  project_id = mongodbatlas_project.project.id
  # Use the cluster name to lookup the cluster and read computed attributes
  name = mongodbatlas_cluster.m0.name
  depends_on = [mongodbatlas_cluster.m0]
}
