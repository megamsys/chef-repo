maintainer       "Megam Systems"
maintainer_email "thomasalrin@megam.io"
license          "Apache 2.0"
description      "Installs/Configures nodejs"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.3.0"
name             "megam_nodejs"
provides         "nodejs"

%w{ build-essential yum-epel ark apt git nginx }.each do |cookbooks|
  depends cookbooks
end

depends "megam_nginx"
depends "git"
depends "megam_deps"
depends "megam_environment"
depends "megam_preinstall"
depends "megam_start"

%w{ debian ubuntu centos redhat smartos }.each do |os|
    supports os
end

conflicts 'node'

suggests 'application_nodejs'
