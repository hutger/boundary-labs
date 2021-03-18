terraform {
  required_providers {
    boundary = {
      source = "hashicorp/boundary"
      version = "1.0.1"
    }
  }
}

provider "boundary" {
  addr                            = "http://[CHANGE_HERE]:9200"
  auth_method_id                  = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "CHANGE_HERE"
}
