# Setup

Tools you need

- Terraform
- AWS cli

## AWS CLI Setup

1. Create a Access key in the AWS Sandbox account

1. Login to AWS CLI, enter your access key and secret access key, region is also critical (it must match the region defined here)

```
$ aws configure
AWS Access Key ID [****************]:
AWS Secret Access Key [****************]:
Default region name [us-east-2]: us-east-2
Default output format [None]:
```

## Terraform Setup

1. Setup Terraform locally

```
$ terraform init
```

You need to fill in the following in `variables.tf`:

- project_name
- pachd_image_tag
- worker_image_tag
- enterprise_license_key
- dns_name (See note below)

# Importants Notes

- We have a chicken and egg problem with the Host/IP of the proxy load balancer. You will need to leave `var.dns_name` blank initially, and then fill it in with the FQDN of the proxy load balancer once it's been provisioned.s

- Your local IP will be added to the database security group, this is required for TF to talk to RDS
