name             "megam_postgresql_server"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures postgresql for clients or servers"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version           "1.0.3"
recipe            "megam_postgresql_server", "Includes postgresql::client"
recipe            "megam_postgresql_server::apt_postgresql_ppa ", "Includes ubuntu sources for PostgreSQL 9.1"
recipe            "megam_postgresql_server::client", "Installs postgresql client package(s)"
recipe            "megam_postgresql_server::server", "Installs postgresql server packages, templates"
recipe            "megam_postgresql_server::server_redhat", "Installs postgresql server packages, redhat family style"
recipe            "megam_postgresql_server::server_debian", "Installs postgresql server packages, debian family style"
recipe            "megam_postgresql_server::setup", "Create users/databases from data bags"

%w{ ubuntu debian fedora suse }.each do |os|
  supports os
end

%w{redhat centos scientific}.each do |el|
  supports el, ">= 6.0"
end

depends "apt"
depends "openssl"

#depends "megam_route53"

depends "megam_sandbox"
depends "apt"
