maintainer       "Thomas Alrin(Megam Systems)"
maintainer_email "alrin@megam.co.in"
license          "Apache 2.0"
description      "Installs/Configures nodejs"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.4"
name             "megam_nodejs"
provides         "nodejs"

recipe "megam_nodejs", "Installs Node.JS based on the default installation method"
recipe "megam_nodejs::install_from_source", "Installs Node.JS from source"
recipe "megam_nodejs::install_from_binary", "Installs Node.JS from official binaries"
recipe "megam_nodejs::install_from_package", "Installs Node.JS from packages"
recipe "megam_nodejs::npm", "Installs npm from source - a package manager for node"

%w{ megam_route53 build-essential apt git megam_deps megam_logstash}.each do |cookbooks|
  depends cookbooks
end

%w{ debian ubuntu centos redhat smartos }.each do |os|
    supports os
end
