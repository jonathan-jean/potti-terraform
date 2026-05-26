resource "openstack_lb_loadbalancer_v2" "potti_loadbalancer" {
  name          = "potti_loadbalancer_par"
  region        = local.primary_region
  vip_subnet_id = openstack_networking_subnet_v2.private_network_potti_par_subnet.id
  depends_on    = [openstack_networking_subnet_v2.private_network_potti_par_subnet]
}

resource "openstack_networking_floatingip_v2" "potti_loadbalancer_floating_ip" {
  region     = local.primary_region
  pool       = "Ext-Net"
  depends_on = [openstack_lb_loadbalancer_v2.potti_loadbalancer]
}

resource "openstack_networking_floatingip_associate_v2" "potti_loadbalancer_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.potti_loadbalancer_floating_ip.address
  port_id     = openstack_lb_loadbalancer_v2.potti_loadbalancer.vip_port_id
  region      = local.primary_region
  depends_on  = [openstack_networking_floatingip_v2.potti_loadbalancer_floating_ip]
}

resource "openstack_lb_listener_v2" "potti_loadbalancer_http_listener" {
  region          = local.primary_region
  name            = "potti_loadbalancer_http_listener"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.potti_loadbalancer.id
  depends_on      = [openstack_lb_loadbalancer_v2.potti_loadbalancer]

  insert_headers = {
    X-Forwarded-For = "true"
    X-Forwarded-Proto = "true"
  }
}

resource "openstack_lb_l7policy_v2" "potti_http_to_https_policy" {
  region          = local.primary_region
  name            = "potti_http_to_https_policy"
  action          = "REDIRECT_PREFIX"
  redirect_prefix = "https://${openstack_networking_floatingip_v2.potti_loadbalancer_floating_ip.address}"
  listener_id     = openstack_lb_listener_v2.potti_loadbalancer_http_listener.id
  depends_on      = [openstack_lb_listener_v2.potti_loadbalancer_http_listener]
}

resource "openstack_lb_l7rule_v2" "potti_http_to_https_rule" {
  region       = local.primary_region
  l7policy_id  = openstack_lb_l7policy_v2.potti_http_to_https_policy.id
  type         = "PATH"
  compare_type = "STARTS_WITH"
  value        = "/"
  depends_on   = [openstack_lb_l7policy_v2.potti_http_to_https_policy]
}

resource "openstack_lb_listener_v2" "potti_loadbalancer_https_listener" {
  region          = local.primary_region
  name            = "potti_loadbalancer_https_listener"
  protocol        = "HTTPS"
  protocol_port   = 443
  loadbalancer_id = openstack_lb_loadbalancer_v2.potti_loadbalancer.id
  depends_on      = [openstack_lb_loadbalancer_v2.potti_loadbalancer]
}

resource "openstack_lb_pool_v2" "potti_loadbalancer_https_pool" {
  region      = local.primary_region
  name        = "potti_loadbalancer_https_pool"
  protocol    = "PROXYV2"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.potti_loadbalancer_https_listener.id
  depends_on  = [openstack_lb_listener_v2.potti_loadbalancer_https_listener]
}

resource "openstack_lb_member_v2" "potti_loadbalancer_https_member" {
  for_each = {
    for vm in local.server_name_list : "${vm.name}" => "${vm}"
  }
  region        = local.primary_region
  name          = "potti_loadbalancer_https_member_${each.value.name}"
  address       = each.value.ip_address
  protocol_port = 443
  pool_id       = openstack_lb_pool_v2.potti_loadbalancer_https_pool.id
  depends_on    = [openstack_lb_pool_v2.potti_loadbalancer_https_pool]
}

resource "openstack_lb_monitor_v2" "potti_loadbalancer_https_monitor" {
  region         = local.primary_region
  name           = "potti_loadbalancer_https_monitor"
  pool_id        = openstack_lb_pool_v2.potti_loadbalancer_https_pool.id
  type           = "TCP"
  delay          = 10
  timeout        = 5
  max_retries    = 3
  depends_on     = [openstack_lb_member_v2.potti_loadbalancer_https_member]
}

# IoT Sensor TCP Listener on port 49984
resource "openstack_lb_listener_v2" "potti_loadbalancer_iot_listener" {
  region          = local.primary_region
  name            = "potti_loadbalancer_iot_listener"
  protocol        = "TCP"
  protocol_port   = 49984
  loadbalancer_id = openstack_lb_loadbalancer_v2.potti_loadbalancer.id
  depends_on      = [openstack_lb_loadbalancer_v2.potti_loadbalancer]
}

resource "openstack_lb_pool_v2" "potti_loadbalancer_iot_pool" {
  region      = local.primary_region
  name        = "potti_loadbalancer_iot_pool"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.potti_loadbalancer_iot_listener.id
  depends_on  = [openstack_lb_listener_v2.potti_loadbalancer_iot_listener]
}

resource "openstack_lb_member_v2" "potti_loadbalancer_iot_member" {
  for_each = {
    for vm in local.server_name_list : "${vm.name}" => "${vm}"
  }
  region        = local.primary_region
  name          = "potti_loadbalancer_iot_member_${each.value.name}"
  address       = each.value.ip_address
  protocol_port = 49984
  pool_id       = openstack_lb_pool_v2.potti_loadbalancer_iot_pool.id
  depends_on    = [openstack_lb_pool_v2.potti_loadbalancer_iot_pool]
}

resource "openstack_lb_monitor_v2" "potti_loadbalancer_iot_monitor" {
  region      = local.primary_region
  name        = "potti_loadbalancer_iot_monitor"
  pool_id     = openstack_lb_pool_v2.potti_loadbalancer_iot_pool.id
  type        = "TCP"
  delay       = 10
  timeout     = 5
  max_retries = 3
  depends_on  = [openstack_lb_member_v2.potti_loadbalancer_iot_member]
}
