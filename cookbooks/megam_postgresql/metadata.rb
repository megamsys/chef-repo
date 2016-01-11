name              "megam_postgresql"
maintainer        "Megam Systems"
maintainer_email  "thomasalrin@megam.io"
license           "Apache 2.0"
description       "Installs and configures postgresql for clients or servers"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "3.4.12"



supports "ubuntu", "< 14.04"

%w{debian fedora suse amazon}.each do |os|
  supports os
end

%w{redhat centos scientific oracle}.each do |el|
  supports el, "~> 6.0"
end

depends "apt"
depends "build-essential"
depends "openssl"

depends "git"
depends "megam_route"

