# This repo contains the terraform code for deploying a Pachyderm cluster on AWS. It currently makes many assumptions about the environment it is being deployed in. It is not intended to be a general purpose Pachyderm deployment tool yet

## Before running terraform destroy, run these commands

### If you find this, do not use it until this warning is removed or you are willing to make changes to the code to suit your needs

Make sure to replace `<project-name>` with the name of the project you are destroying. This will remove the resources that were created by the `postgresql_grant` and `postgresql_database` resources. If you do not do this, terraform will almost always fail to destroy the resources.

```bash
terraform state rm module.<project-name>.module.pach_rds.postgresql_grant.full_crud_pachyderm
terraform state rm module.<project-name>.module.pach_rds.postgresql_grant.full_crud_dex
terraform state rm module.<project-name>.module.pach_rds.postgresql_database.dex
```
