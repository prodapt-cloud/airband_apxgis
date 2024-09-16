

resource "azurerm_monitor_diagnostic_setting" "main" {
  name               = var.monitor_name
  target_resource_id = var.target_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }

  # Correct log block
  #log {
  #  category = "Administrative"
 #   enabled  = true
   # retention_policy {
     # enabled = false
    }
  #}
#}