terraform {
  cloud {
    organization = "hirokisakabe"
    workspaces {
      name = "azure-application-insights-nextjs-sample" 
    }
  }
  required_version = ">= 1.9.7"
}

provider "azurerm" {
  features {}
}

locals {
  project_name = "appinextjs"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.project_name}"
  location = "japanwest"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${local.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_application_insights" "this" {
  name                = "appinsights-${local.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
}

resource "azurerm_container_registry" "this" {
  name                = "registry${local.project_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_service_plan" "this" {
  name                = "webapp-asp-${local.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "this" {
  name                = "webapp-${local.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  depends_on          = [azurerm_service_plan.this]
  https_only          = true
  site_config {
    container_registry_use_managed_identity = true
    application_stack {
      docker_image_name   = "app:latest"
      docker_registry_url = "https://${azurerm_container_registry.this.login_server}"
    }
  }
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.this.connection_string
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "webapp_acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}
