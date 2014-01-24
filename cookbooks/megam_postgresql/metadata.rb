name             "megam_postgresql"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures postgresql for clients or servers"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version           "1.0.3"

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

depends "megam_ganglia"

depends "git"
depends "megam_route53"

depends "megam_logstash"
depends "megam_gulp"
