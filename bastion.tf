resource "openstack_networking_port_v2" "bastion_port" {
  name           = "bastion_port"
  region         = local.primary_region
  network_id     = openstack_networking_network_v2.private_network_potti_par.id
  admin_state_up = "true"
  security_group_ids = [
    openstack_networking_secgroup_v2.bastion_french_only_secgroup.id,
    openstack_networking_secgroup_v2.tailscale_secgroup.id
  ]

  fixed_ip {
    ip_address = var.bastion_server.ip_address
    #subnet_id = openstack_networking_subnet_v2.private_network_potti_par_subnet.id
  }
}

resource "openstack_networking_floatingip_v2" "bastion_floating_ip" {
  region = local.primary_region
  pool   = "Ext-Net"
}

resource "openstack_networking_floatingip_associate_v2" "bastion_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.bastion_floating_ip.address
  port_id     = openstack_networking_port_v2.bastion_port.id
  region      = local.primary_region
  depends_on  = [openstack_networking_router_interface_v2.potti_router_interface]
}

resource "openstack_compute_instance_v2" "bastion" {
  name              = var.bastion_server.name
  provider          = openstack
  image_name        = var.bastion_server.image
  flavor_name       = var.bastion_server.flavor
  region            = local.primary_region
  availability_zone = lower(var.bastion_server.region)
  key_pair          = openstack_compute_keypair_v2.ssh_key[local.primary_region].name
  security_groups   = [openstack_networking_secgroup_v2.bastion_french_only_secgroup.name]
  network {
    port = openstack_networking_port_v2.bastion_port.id
  }
  network {
    name = "Ext-Net"
  }
  depends_on = [openstack_networking_port_v2.bastion_port]
  lifecycle {
    ignore_changes = [
      image_name
    ]
  }
  stop_before_destroy = true
}
