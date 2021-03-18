resource "boundary_scope" "global" {
  global_scope = true
  description  = "Global Scope"
  scope_id     = "global"
}

resource "boundary_scope" "corp" {
  name                     = "MyCorp"
  description              = "My first scope!"
  scope_id                 = boundary_scope.global.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

## Use password auth method
resource "boundary_auth_method" "password" {
  name     = "MyCorp Password"
  scope_id = boundary_scope.corp.id
  type     = "password"
}






## Create user accounts with password: password
resource "boundary_account" "admin_users_acct" {
  for_each       = var.admin_users
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_account" "readonly_users_acct" {
  for_each       = var.readonly_users
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_account" "linux_users_acct" {
  for_each       = var.linux_users
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_account" "windows_users_acct" {
  for_each       = var.windows_users
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}





resource "boundary_user" "admin_users" {
  for_each    = var.admin_users
  name        = each.key
  description = "User resource for ${each.key}"
  account_ids = [ boundary_account.admin_users_acct[each.key].id ]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_user" "readonly_users" {
  for_each    = var.readonly_users
  name        = each.key
  description = "User resource for ${each.key}"
  account_ids = [ boundary_account.readonly_users_acct[each.key].id ]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_user" "linux_users" {
  for_each    = var.linux_users
  name        = each.key
  description = "User resource for ${each.key}"
  account_ids = [ boundary_account.linux_users_acct[each.key].id ]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_user" "windows_users" {
  for_each    = var.windows_users
  name        = each.key
  description = "User resource for ${each.key}"
  account_ids = [ boundary_account.windows_users_acct[each.key].id ]
  scope_id    = boundary_scope.corp.id
}






resource "boundary_group" "admin_group" {
  name        = "admin_group"
  description = "Organization group for admin users"
  member_ids  = [for user in boundary_user.admin_users : user.id]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_group" "readonly_group" {
  name        = "readonly_group"
  description = "Organization group for readonly group"
  member_ids  = [for user in boundary_user.readonly_users : user.id]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_group" "linux_group" {
  name        = "linux_group"
  description = "Organization group for linux group"
  member_ids  = [for user in boundary_user.linux_users : user.id]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_group" "windows_group" {
  name        = "windows_group"
  description = "Organization group for windows group"
  member_ids  = [for user in boundary_user.windows_users : user.id]
  scope_id    = boundary_scope.corp.id
}




resource "boundary_role" "admin_role" {
  name        = "admin_role"
  description = "Admin role"
  principal_ids = [boundary_group.admin_group.id]
  grant_strings = ["id=*;type=*;actions=*"]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_role" "readonly_role" {
  name        = "readonly_role"
  description = "ReadOnly role"
  principal_ids = [boundary_group.readonly_group.id]
  grant_strings = ["id=*;type=*;actions=list,read"]
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_role" "linux_role" {
  name        = "linux_role"
  description = "linux role"
  principal_ids = [boundary_group.linux_group.id]
  grant_strings = ["id=*;type=*;actions=read,list,authorize-session"]
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_role" "windows_role" {
  name        = "windows_role"
  description = "windows role"
  principal_ids = [boundary_group.windows_group.id]
  grant_strings = ["id=*;type=*;actions=read,list,authorize-session"]
  scope_id    = boundary_scope.corp.id
}

# This role is required as per https://github.com/hashicorp/boundary/issues/1002

resource "boundary_role" "boundary-desktop-role" {
  name        = "boundary-desktop-role"
  description = "Boundary Desktop Role"
  principal_ids = [boundary_group.linux_group.id, boundary_group.windows_group.id]
  grant_strings = ["id=*;type=target;actions=read,list,authorize-session", "id=*;type=session;actions=read,list,authorize-session"]
  scope_id    = boundary_scope.corp.id
}

# ----

resource "boundary_scope" "core_infra" {
  name                   = "Core infrastrcture"
  description            = "My first project!"
  scope_id               = boundary_scope.corp.id
  auto_create_admin_role = true
}

resource "boundary_host_catalog" "backend_servers" {
  name        = "backend_servers"
  description = "Backend servers host catalog"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "linux_backend" {
  for_each        = var.linux_backend
  type            = "static"
  name            = "backend_server_service_${each.value}"
  description     = "Backend server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

resource "boundary_host" "windows_backend" {
  for_each        = var.windows_backend
  type            = "static"
  name            = "backend_server_service_${each.value}"
  description     = "Backend server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

resource "boundary_host_set" "linux_backend" {
  type            = "static"
  name            = "linux_backend"
  description     = "Host set for backend servers"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.linux_backend : host.id]
}

resource "boundary_host_set" "windows_backend" {
  type            = "static"
  name            = "windows_backend"
  description     = "Host set for backend Windows servers"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.windows_backend : host.id]
}

# create target for accessing backend servers on port :8080
// resource "boundary_target" "backend_servers_service" {
//   type         = "tcp"
//   name         = "Backend service"
//   description  = "Backend service target"
//   scope_id     = boundary_scope.core_infra.id
//   default_port = "8080"

//   host_set_ids = [
//     boundary_host_set.backend_servers_ssh .id
//   ]
// }

# create target for accessing backend servers on port :22
resource "boundary_target" "linux_backend_ssh" {
  type         = "tcp"
  name         = "Backend SSH"
  description  = "Backend SSH target"
  scope_id     = boundary_scope.core_infra.id
  default_port = "22"

  host_set_ids = [
    boundary_host_set.linux_backend.id
  ]
}

# create target for accessing backend servers on port :3389
resource "boundary_target" "windows_backend_rdp" {
  type         = "tcp"
  name         = "Backend RDP"
  description  = "Backend RDP target"
  scope_id     = boundary_scope.core_infra.id
  default_port = "3389"
  session_connection_limit = 2
  host_set_ids = [
    boundary_host_set.windows_backend.id
  ]
}