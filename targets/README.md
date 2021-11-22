# Target postgresql for Boundary demonstration

This project deploy a postgresql in AWS as a target for the Boundary demonstration.

## How is it working?

Run this command: `$ terraform apply`

When your stack is deploy, do the following steps:
1. In **Boundary**, do an initial setup: create a project, host catalog, user, permission, etc.
2. In **Boundary**, create a **host** based on `$ terraform output -raw rds_endpoint`
3. In **Boundary**, create a **target** based on `$ terraform output -raw rds_endpoint`
4. Use [Boundary Desktop](https://learn.hashicorp.com/tutorials/boundary/getting-started-desktop-app) and connect into a **target**.
5. Based on the **Proxy URL (TCP)** provided by Boundary Desktop, do the follow command and change the port (here: `53424`): `$ PGPASSWORD="$(terraform output -raw rds_password)" psql -h 127.0.0.1 -p 53424 -d app -U app`

When you etablish a Session into the Target, you should have the following output:
```bash
psql (14.1, server 11.8)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

app=> exit
```

> You can skip with the `exit` command

Well done! You have just etablish your first Session.

You can also test the [HashiCorp Learn - Boundary getting start](https://learn.hashicorp.com/tutorials/boundary/getting-started-console?in=boundary/getting-started).

## Clean it

> You should clean the target before Boundary project (parent project)

Run this command: `$ terraform destroy`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.63.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_password.db_master_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_remote_state.boundary](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | The application name. | `string` | `"boundary-target"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | The database instance size & type. | `string` | `"db.t2.micro"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The database name. | `string` | `"app"` | no |
| <a name="input_db_storage"></a> [db\_storage](#input\_db\_storage) | The database storage in GB. | `number` | `20` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | The admin username for the database. | `string` | `"app"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the application or the owner of the deployed stack. | `string` | `"Terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"eu-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_dbname"></a> [rds\_dbname](#output\_rds\_dbname) | n/a |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | n/a |
| <a name="output_rds_password"></a> [rds\_password](#output\_rds\_password) | n/a |
| <a name="output_rds_username"></a> [rds\_username](#output\_rds\_username) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

