resource "azurerm_resource_group" "aks_demo_rg" {
  name     = var.resource_group
  location = var.azure_region
}

resource "azurerm_kubernetes_cluster" "aks_k2" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_demo_rg.location
  resource_group_name = azurerm_resource_group.aks_demo_rg.name
  dns_prefix          = var.dns_name
  kubernetes_version  = var.kubernetes_version

  dynamic "agent_pool_profile" {
    for_each = var.agent_pools
    iterator = pool
    content {
      name            = pool.value.name
      count           = pool.value.count
      vm_size         = pool.value.vm_size
      os_type         = pool.value.os_type
      os_disk_size_gb = pool.value.os_disk_size_gb
      type            = "VirtualMachineScaleSets"
      max_pods        = 100
      vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    }
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_public_key.value
    }
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"     # Options are calico or azure - only if network plugin is set to azure
    dns_service_ip     = "172.16.0.10" # Required when network plugin is set to azure, must be in the range of service_cidr and above 1
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "172.16.0.0/16" # Must not overlap any address from the VNEt
  }


  role_based_access_control {
    enabled = true
  }

  service_principal {
    client_id     = data.azurerm_key_vault_secret.spn_id.value
    client_secret = data.azurerm_key_vault_secret.spn_secret.value
  }

  tags = {
    Environment = "Demo"
  }
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.aks_k2.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks_k2.kube_config_raw}"
}
