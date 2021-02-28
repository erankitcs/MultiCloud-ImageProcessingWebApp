variable "app_version" {
    type = string
    description = "Version of the application."
}

variable "azure_resource_group" {
  type = string
  description = "Resource Group Name for Azure Resources."
}

variable "gcp_project_name" {
  type = string
  description = "Project Name of GCP under which resources will be created."
}