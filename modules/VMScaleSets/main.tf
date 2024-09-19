# Locals Block for custom data
locals {
  webvm_custom_data = <<CUSTOM_DATA
#!/bin/bash
# Update the package list
sudo apt-get update -y

# Install Apache HTTPD
sudo apt-get install -y apache2

# Enable and start Apache service
sudo systemctl enable apache2
sudo systemctl start apache2

# Disable and stop firewall (Ubuntu uses ufw)
sudo ufw disable

# Set permissions for /var/www/html
sudo chmod -R 777 /var/www/html

# Create a basic index.html file
sudo echo "Welcome to stacksimplify - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/index.html

# Create directories and additional HTML pages
sudo mkdir /var/www/html/app1
sudo echo "Welcome to stacksimplify - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/app1/hostname.html
sudo echo "Welcome to stacksimplify - WebVM App1 - App Status Page" > /var/www/html/app1/status.html

# Create a custom index.html page for app1 with styling
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>Welcome to Stack Simplify - WebVM APP-1 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html

# Fetch instance metadata and save it to metadata.html
sudo curl -H "Metadata:true" --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" -o /var/www/html/app1/metadata.html
CUSTOM_DATA
}



# Resource: Azure Linux Virtual Machine Scale Set - App1
resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "AIRBAND-web-vmss"
  #computer_name_prefix = "vmss-app1" # if name argument is not valid one for VMs, we can use this for VM Names
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard_DS1_v2"
  instances           = 2
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
  }

source_image_reference {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "20_04-lts"  # For Ubuntu LTS
  version   = "latest"
}

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  upgrade_mode = "Automatic"
  
  network_interface {
    name    = "web-vmss-nic"
    primary = true
    network_security_group_id = module.secritygroup.azurerm_network_security_group.web-nsg.id
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = module.networking.websubnet_id
      #load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id]
      application_gateway_backend_address_pool_ids = [backendpool_id]            
    }
  }
        
  custom_data = base64encode(local.webvm_custom_data)  
}
  