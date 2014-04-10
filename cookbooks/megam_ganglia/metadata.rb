name             'megam_ganglia'
maintainer       "Megam Systems"
maintainer_email "alrin@megam.co.in"
license          "Apache 2.0"
description      "Installs/Configures ganglia"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.2.0"

%w{ debian ubuntu redhat centos fedora }.each do |os|
  supports os
end

recommends "graphite"
suggests "iptables"

depends "runit"
depends "megam_sandbox"
