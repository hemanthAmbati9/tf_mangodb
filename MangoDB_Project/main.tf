# Create an Atlas Project inside the existing Organization
resource "mongodbatlas_project" "project" {
  org_id = var.org_id
  name   = var.project_name
}

# Create the free tier M0 cluster
# NOTE: M0 clusters have limitations (one M0 per project, limited config) — Atlas will list available regions for M0.
resource "mongodbatlas_cluster" "mongo" {
  project_id = mongodbatlas_project.project.id
  name       = var.cluster_name

  cluster_type                  = "REPLICASET"
  provider_name                 = "AWS"          # or "GCP" / "AZURE"
  provider_region_name          = var.cluster_region
  provider_instance_size_name   = "M0"           # Free tier instance
  mongo_db_major_version        = "7.0"          # Latest supported version
  auto_scaling_disk_gb_enabled  = false
  backup_enabled                = false

  lifecycle {
    prevent_destroy = false
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
}


# Data source (retrieve computed connection strings once cluster exists)
data "mongodbatlas_cluster" "cluster_info" {
  project_id = mongodbatlas_project.project.id
  # Use the cluster name to lookup the cluster and read computed attributes
  name = mongodbatlas_cluster.mongo.name
  depends_on = [mongodbatlas_cluster.mongo]
}
