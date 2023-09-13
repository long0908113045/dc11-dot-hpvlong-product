data "terraform_remote_state" "dc11-dot-hpvlong-product-terraform-state" {
  backend = "s3"
  config = {
    bucket         = "dc11-dot-hpvlong-networking-terraform-state"
    key            = "env:/${terraform.workspace}/terraform.tfstate"
    region         = "ap-southeast-1"
  }
}