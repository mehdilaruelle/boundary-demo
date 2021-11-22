data "terraform_remote_state" "boundary" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}
