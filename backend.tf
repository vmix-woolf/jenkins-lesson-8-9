terraform {
  backend "s3" {
    bucket       = "terraform-state-lesson-8-9-mykhailov-viacheslav-20260628"
    key          = "lesson-8-9/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}