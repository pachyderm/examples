module "pachyderm-deployment" {
  source = "./modules/project_deploy"

  index             = 0
  name              = "pach-demo"
  aws_region        = "us-east-2"
  admin_user        = "brody.osterbuhr@pachyderm.io"
  pach_version      = "2.5.0-alpha.4"
  pachd_image_tag   = "2.5.0-alpha.4"
  worker_image_tag  = "2.5.0-alpha.4"
  console_image_tag = "2.5.0-alpha.4"

  enable_karpenter = true
  enable_cloudflare = true
  enable_notebooks = true
  #TODO: split out oidc secrets into their own modules and pick one here
}