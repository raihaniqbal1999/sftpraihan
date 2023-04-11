# terraform-az-blob-clamav (under construction)
ClamAV virus scanner for azure storage accounts

This module assumes you have a latest version of azure cli (func --version >= 3.0.0) and **docker** or **limavm** installed.

>WARNING: this module attempts to deploy function code via 'func azure functionapp publish ...' if you are on KPMG vpn this may fail due to proxy. If that is the case after terraform deploy cd to functions folder and issue ```func azure functionapp publish <FUNCTIONAPP_NAME>```

>WARNING: this module can be used to build/deploy docker image for you if the runner has either **docker or limavm** installed. Without the image deployment will fail as you cant create container instance with empty container registry. If you wish to deploy the image your self set ```experimental_deploy_runner = none``` or leave it unset. The module deployment will fail so you will have to run it again after you pushed the image ( this only applies to first time deployment)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=2.78.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=2.78.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >=3.1.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_plan.triggers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan) | resource |
| [azurerm_application_insights.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_container_group.clamav_scanner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_container_group.clamav_update](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_container_registry.clamav](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_eventgrid_system_topic.blob_created](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic) | resource |
| [azurerm_eventgrid_system_topic_event_subscription.servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic_event_subscription) | resource |
| [azurerm_function_app.clamav_triggers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) | resource |
| [azurerm_monitor_action_group.new_notifications](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_metric_alert.sb_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_role_assignment.function_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.aci_triggers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_servicebus_namespace.event_queues](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_queue.clean](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_queue.incoming](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_queue.infected](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_storage_account.func_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.incoming](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.virus_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.virus_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [null_resource.deploy_container](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.deploy_func_triggers](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_functionapp](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_function_app_host_keys.triggers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/function_app_host_keys) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Specify the environment for the deployed resources eg UAT, PROD, DEV | `string` | n/a | yes |
| <a name="input_function_storage"></a> [function\_storage](#input\_function\_storage) | Storage account for function app triggers code | `string` | n/a | yes |
| <a name="input_geo_location"></a> [geo\_location](#input\_geo\_location) | Azure location for the resources to be deployed to eg. uksouth | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Provide github repository url so we can easly identify which repo the resources have been deployed from | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Azure Resource Group name as deployment target | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to be added to every resource that will be created by this module (excluding storage accounts) | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription id eg xxxx-xxxxxx-xxxxxx-xxxx | `string` | n/a | yes |
| <a name="input_virus_db_storage"></a> [virus\_db\_storage](#input\_virus\_db\_storage) | Storage account for virus db files used by clamAV | `string` | n/a | yes |
| <a name="input_appinsights_conn_string"></a> [appinsights\_conn\_string](#input\_appinsights\_conn\_string) | The connection string for Application Insights | `string` | `""` | no |
| <a name="input_appinsights_instrumentationkey"></a> [appinsights\_instrumentationkey](#input\_appinsights\_instrumentationkey) | The instrumentation key for Application Insights | `string` | `""` | no |
| <a name="input_create_app_insight"></a> [create\_app\_insight](#input\_create\_app\_insight) | Set this to false if the Application Insights component already exists | `bool` | `true` | no |
| <a name="input_create_eventgrid_system_topic"></a> [create\_eventgrid\_system\_topic](#input\_create\_eventgrid\_system\_topic) | Set this to false if there is an existing system topic for the given source | `bool` | `true` | no |
| <a name="input_create_incoming_sa"></a> [create\_incoming\_sa](#input\_create\_incoming\_sa) | Set this to false if the storage account to be scanned already exists | `bool` | `true` | no |
| <a name="input_create_output_clean_queue"></a> [create\_output\_clean\_queue](#input\_create\_output\_clean\_queue) | Create output queue for 'clean files' so it can be used by other functionality (default is true) | `bool` | `true` | no |
| <a name="input_create_output_infected_queue"></a> [create\_output\_infected\_queue](#input\_create\_output\_infected\_queue) | Create output queue for 'infected files' so it can be used by other functionality (default is true) | `bool` | `true` | no |
| <a name="input_event_subject_filter"></a> [event\_subject\_filter](#input\_event\_subject\_filter) | Specify a starting value for filtering the subject of each event(Only events with matching subjects get delivered) | `string` | `""` | no |
| <a name="input_eventgrid_system_topic_name"></a> [eventgrid\_system\_topic\_name](#input\_eventgrid\_system\_topic\_name) | The System Topic where the Event Subscription should be created in | `string` | `""` | no |
| <a name="input_experimental_deploy_runner"></a> [experimental\_deploy\_runner](#input\_experimental\_deploy\_runner) | Run image build / deploy from terraform possible values (docker, limavm, none) | `string` | `"none"` | no |
| <a name="input_experimental_image_repo_ref"></a> [experimental\_image\_repo\_ref](#input\_experimental\_image\_repo\_ref) | docker repository reference to be shallow cloned | `string` | `"main"` | no |
| <a name="input_function_app_tags"></a> [function\_app\_tags](#input\_function\_app\_tags) | Tags to be added to the function app | `map(string)` | `{}` | no |
| <a name="input_function_storage_tags"></a> [function\_storage\_tags](#input\_function\_storage\_tags) | Additonal tags to be added to this storage account | `map(string)` | `{}` | no |
| <a name="input_incoming_files_storage"></a> [incoming\_files\_storage](#input\_incoming\_files\_storage) | Storage account for incoming files that need to be continously scanned by clamAV | `string` | `""` | no |
| <a name="input_incoming_files_storage_tags"></a> [incoming\_files\_storage\_tags](#input\_incoming\_files\_storage\_tags) | Addtional tags to be added to this storage account | `map(string)` | `{}` | no |
| <a name="input_incoming_storage_conn_string"></a> [incoming\_storage\_conn\_string](#input\_incoming\_storage\_conn\_string) | Connection string of the incoming storage account | `string` | `""` | no |
| <a name="input_incoming_storage_id"></a> [incoming\_storage\_id](#input\_incoming\_storage\_id) | Resource ID of the incoming storage account | `string` | `""` | no |
| <a name="input_scanner_container_memory"></a> [scanner\_container\_memory](#input\_scanner\_container\_memory) | Memory required for the clamav scanner container in GB | `string` | `"1.5"` | no |
| <a name="input_system_topic_resource_group_name"></a> [system\_topic\_resource\_group\_name](#input\_system\_topic\_resource\_group\_name) | Resource Group name for Event Grid System Topic that matches the source resource group (Required when source storage account exists in different resource group than other clamav resources) | `string` | `""` | no |
| <a name="input_virus_db_storage_tags"></a> [virus\_db\_storage\_tags](#input\_virus\_db\_storage\_tags) | Additonal tags to be added to this storage account | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_clamav_trigger_functionapp_id"></a> [clamav\_trigger\_functionapp\_id](#output\_clamav\_trigger\_functionapp\_id) | n/a |
| <a name="output_incoming_queue"></a> [incoming\_queue](#output\_incoming\_queue) | n/a |
| <a name="output_incoming_storage_account_conn_string"></a> [incoming\_storage\_account\_conn\_string](#output\_incoming\_storage\_account\_conn\_string) | n/a |
| <a name="output_incoming_storage_account_name"></a> [incoming\_storage\_account\_name](#output\_incoming\_storage\_account\_name) | n/a |
| <a name="output_output_clean_queue"></a> [output\_clean\_queue](#output\_output\_clean\_queue) | n/a |
| <a name="output_output_infected_queue"></a> [output\_infected\_queue](#output\_output\_infected\_queue) | n/a |
| <a name="output_servicebus_conn_string"></a> [servicebus\_conn\_string](#output\_servicebus\_conn\_string) | n/a |
| <a name="output_servicebus_id"></a> [servicebus\_id](#output\_servicebus\_id) | n/a |
| <a name="output_servicebus_namespace"></a> [servicebus\_namespace](#output\_servicebus\_namespace) | n/a |
| <a name="output_update_container_group_name"></a> [update\_container\_group\_name](#output\_update\_container\_group\_name) | n/a |