

output "backendpool_id" {
  value = [azurerm_application_gateway.web_ag.backend_address_pool[0].id]
  description = "back end pool id"
}