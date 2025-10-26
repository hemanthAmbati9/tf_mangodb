# The SRV connection string (no credentials). Example: mongodb+srv://<host>/ (you will need to add username/password).
# output "mongodb_srv" {
#   description = "Atlas SRV connection host (no credentials included). Use mongodb+srv://<username>:<password>@<host>/"
#   value       = try(data.mongodbatlas_cluster.cluster_info.connection_strings[0].standard_srv, "")
#   sensitive   = false
# }

# # Build a full connection URI with username embedded (DO NOT print password in logs)
# output "mongodb_uri_with_username" {
#   description = "A connection URI with username (password not embedded). If you want the full URI include password carefully."
#   value       = "mongodb+srv://${mongodbatlas_database_user.db_user.username}@${try(data.mongodbatlas_cluster.cluster_info.connection_strings[0].standard_srv, "")}/?retryWrites=true&w=majority"
#   sensitive   = false
# }

# # OPTIONAL: If you really want to output the full connection string (username:password) — mark as sensitive=true
# output "mongodb_uri_full_sensitive" {
#   description = "Full connection URI including password (sensitive). Use `terraform output -raw mongodb_uri_full_sensitive` to read it locally."
#   value       = "mongodb+srv://${mongodbatlas_database_user.db_user.username}:${var.db_password}@${try(data.mongodbatlas_cluster.cluster_info[0].connection_strings[0].standard_srv, data.mongodbatlas_cluster.cluster_info.connection_strings[0].standard_srv)}/?retryWrites=true&w=majority"
#   sensitive   = true
# }

output "mongodb_connection_string" {
  value = mongodbatlas_cluster.m0.connection_strings[0].standard_srv
}
