resource "azurerm_storage_account" "bosh_root_storage_account" {
  name                = "${var.env_short_name}director"
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  location            = "${var.location}"
  account_type        = "Standard_LRS"
}

resource "azurerm_storage_account" "ops_manager_storage_account" {
  name                = "${var.env_short_name}opsmanager"
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  location            = "${var.location}"
  account_type        = "Premium_LRS"
}

resource "azurerm_storage_container" "ops_manager_storage_container" {
  name                  = "opsmanagerimage"
  depends_on            = ["azurerm_storage_account.ops_manager_storage_account"]
  resource_group_name   = "${azurerm_resource_group.pcf_resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.ops_manager_storage_account.name}"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "ops_manager_image" {
  name                   = "opsman.vhd"
  resource_group_name    = "${azurerm_resource_group.pcf_resource_group.name}"
  storage_account_name   = "${azurerm_storage_account.ops_manager_storage_account.name}"
  storage_container_name = "${azurerm_storage_container.ops_manager_storage_container.name}"
  source_uri             = "${var.ops_manager_image_uri}"
}

resource "azurerm_storage_blob" "optional_ops_manager_image" {
  name                   = "optional_opsman.vhd"
  resource_group_name    = "${azurerm_resource_group.pcf_resource_group.name}"
  storage_account_name   = "${azurerm_storage_account.ops_manager_storage_account.name}"
  storage_container_name = "${azurerm_storage_container.ops_manager_storage_container.name}"
  source_uri             = "${var.optional_ops_manager_image_uri}"
}

resource "azurerm_storage_container" "bosh_storage_container" {
  name                  = "bosh"
  depends_on            = ["azurerm_storage_account.bosh_root_storage_account"]
  resource_group_name   = "${azurerm_resource_group.pcf_resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.bosh_root_storage_account.name}"
  container_access_type = "private"
}

resource "azurerm_storage_container" "stemcell_storage_container" {
  name                  = "stemcell"
  depends_on            = ["azurerm_storage_account.bosh_root_storage_account"]
  resource_group_name   = "${azurerm_resource_group.pcf_resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.bosh_root_storage_account.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_table" "stemcells_storage_table" {
  name                 = "stemcells"
  resource_group_name  = "${azurerm_resource_group.pcf_resource_group.name}"
  storage_account_name = "${azurerm_storage_account.bosh_root_storage_account.name}"
}

resource "azurerm_storage_account" "bosh_vms_storage_account" {
  name                = "${var.env_short_name}${data.template_file.base_storage_account_wildcard.rendered}${count.index}"
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  location            = "${var.location}"
  account_type        = "Premium_LRS"

  count = 3
}

resource "azurerm_storage_container" "bosh_vms_storage_container" {
  name                  = "bosh"
  depends_on            = ["azurerm_storage_account.bosh_vms_storage_account"]
  resource_group_name   = "${azurerm_resource_group.pcf_resource_group.name}"
  storage_account_name  = "${element(azurerm_storage_account.bosh_vms_storage_account.*.name, count.index)}"
  container_access_type = "private"

  count = 3
}

resource "azurerm_storage_container" "bosh_vms_stemcell_storage_container" {
  name                  = "stemcell"
  depends_on            = ["azurerm_storage_account.bosh_vms_storage_account"]
  resource_group_name   = "${azurerm_resource_group.pcf_resource_group.name}"
  storage_account_name  = "${element(azurerm_storage_account.bosh_vms_storage_account.*.name, count.index)}"
  container_access_type = "private"

  count = 3
}
