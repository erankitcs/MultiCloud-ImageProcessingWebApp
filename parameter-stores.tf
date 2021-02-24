resource "aws_ssm_parameter" "subscription_key" {
  name  = "/azure/subsctiptionkey"
  type  = "SecureString"
  value = azurerm_cognitive_account.imagelense.primary_access_key
}