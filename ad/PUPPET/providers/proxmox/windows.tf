"dc01" = {
  name               = "DC01"
  desc               = "DC01 - windows server 2025 - {{ip_range}}.10"
  cores              = 4
  memory             = 8192
  clone              = "WinServer2025_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.5/24"
  gateway            = "{{ip_range}}.1"
}
"file01" = {
  name               = "FILE01"
  desc               = "FILE01 - windows server 2025 - {{ip_range}}.21"
  cores              = 4
  memory             = 8192
  clone              = "WinServer2022_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.50/24"
  gateway            = "{{ip_range}}.1"
}
"pm01" = {
  name               = "PM01"
  desc               = "PM01 - windows server 2025 - {{ip_range}}.22"
  cores              = 2
  memory             = 4096
  clone              = "WinServer2025_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.22/24"
  gateway            = "{{ip_range}}.1"
}
