name             "megam_postgresql"
maintainer        "Megam Systems"
maintainer_email  "alrin@megam.co.in"
license           "Apache 2.0"
description       "Installs and configures postgresql for clients or servers"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "3.3.4"

%w{ubuntu debian fedora suse amazon}.each do |os|
  supports os
end

%w{redhat centos scientific oracle}.each do |el|
  supports el, ">= 6.0"
end

depends "apt"
depends "build-essential"
depends "openssl"

depends "megam_sandbox"

depends "megam_ganglia"

depends "git"
depends "megam_route53"
depends "megam_deps"
depends "megam_logstash"
depends "megam_gulp"
