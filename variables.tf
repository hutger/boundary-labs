variable "admin_users" {
  type    = set(string)
  default = [
    "Allan",
    "Anna"
  ]
}

variable "readonly_users" {
  type    = set(string)
  default = [
    "Ryan",
    "Rudd"
  ]
}

variable "linux_users" {
  type    = set(string)
  default = [
    "Lilian",
    "Lew"
  ]
}

variable "windows_users" {
  type    = set(string)
  default = [
    "William",
    "Wendy"
  ]
}

variable "linux_backend" {
  type    = set(string)
  default = [
    "10.0.1.10",
    "10.0.1.20"
  ]
}

variable "windows_backend" {
  type    = set(string)
  default = [
    "10.0.1.30",
    "10.0.1.40"
  ]
}
