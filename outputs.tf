#
# Outputs - Consolidated from all resources
#

#
# App Server Outputs
#

output "app_server_floating_ips" {
  description = "Map of app server names to their floating IPs"
  value = {
    for name, ip in openstack_networking_floatingip_v2.app_server_floating_ip :
    name => ip.address
  }
}

output "app_server_private_ips" {
  description = "Map of app server names to their private IPs"
  value = {
    for vm in local.server_name_list :
    vm.name => vm.ip_address
  }
}

#
# Bastion Outputs
#

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = openstack_networking_floatingip_v2.bastion_floating_ip.address
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = var.bastion_server.ip_address
}

#
# Load Balancer Outputs
#

output "load_balancer_floating_ip" {
  description = "Public IP of the load balancer"
  value       = openstack_networking_floatingip_v2.potti_loadbalancer_floating_ip.address
}

output "load_balancer_vip" {
  description = "Virtual IP of the load balancer (private network)"
  value       = openstack_lb_loadbalancer_v2.potti_loadbalancer.vip_address
}

#
# Database Outputs
#

output "postgres_potti_production_user_password" {
  description = "PostgreSQL production user password"
  value       = ovh_cloud_project_database_postgresql_user.postgres_potti_production_user.password
  sensitive   = true
}

output "postgres_potti_avnadmin_user_password" {
  description = "PostgreSQL admin user password"
  value       = ovh_cloud_project_database_postgresql_user.postgres_potti_avnadmin_user.password
  sensitive   = true
}

output "postgres_endpoint" {
  description = "PostgreSQL connection endpoint"
  value       = ovh_cloud_project_database.potti_postgres.endpoints
}

#
# Cache (Valkey) Outputs
#

output "cache_user_password" {
  description = "Valkey cache user password"
  value       = ovh_cloud_project_database_valkey_user.cache_user.password
  sensitive   = true
}

output "cache_endpoint" {
  description = "Valkey cache connection endpoint"
  value       = ovh_cloud_project_database.potti_cache.endpoints
}

#
# S3 Outputs
#

#output "s3_bucket_region" {
#  description = "Region of the S3 bucket"
#  value       = local.primary_region
#}

#output "s3_bucket_virtual_host" {
#  description = "Virtual host URL of the S3 bucket"
#  value       = var.s3_bucket_config.replication_enabled ? ovh_cloud_project_storage.s3_bucket_replicated[0].virtual_host : ovh_cloud_project_storage.s3_bucket[0].virtual_host
#}

#output "s3_replica_bucket_name" {
#  description = "Name of the S3 replica bucket (if replication is enabled)"
#  value       = var.s3_bucket_config.replication_enabled ? "${var.s3_bucket_config.name}-replica" : null
#}

#output "s3_replica_bucket_region" {
#  description = "Region of the S3 replica bucket (if replication is enabled)"
#  value       = var.s3_bucket_config.replication_enabled ? var.s3_bucket_config.replication_region : null
#}

#output "s3_replica_endpoint" {
#  description = "S3 replica endpoint URL (if replication is enabled)"
#  value       = var.s3_bucket_config.replication_enabled ? "https://s3.${lower(var.s3_bucket_config.replication_region)}.io.cloud.ovh.net" : null
#}

#output "s3_user_credential_access_key" {
#  description = "S3 user access key ID"
#  value       = ovh_cloud_project_user_s3_credential.s3_user_cred.access_key_id
#  sensitive   = true
#}

#output "s3_user_credential_secret_key" {
#  description = "S3 user secret access key"
#  value       = ovh_cloud_project_user_s3_credential.s3_user_cred.secret_access_key
#  sensitive   = true
#}

#output "s3_endpoint" {
#  description = "S3 endpoint URL"
#  value       = "https://s3.${lower(local.primary_region)}.io.cloud.ovh.net"
#}

#
# Network Outputs
#

output "private_network_id" {
  description = "ID of the private network"
  value       = openstack_networking_network_v2.private_network_potti_par.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = openstack_networking_subnet_v2.private_network_potti_par_subnet.id
}
