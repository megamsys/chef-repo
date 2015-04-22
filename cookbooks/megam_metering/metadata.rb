name             'megam_metering'
maintainer       "Megam Systems"
maintainer_email "thomasalrin@megam.io"
license          "Apache 2.0"
description      "Installs/Configures packages for metering vm"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.5.0"

%w{ debian ubuntu redhat centos fedora }.each do |os|
  supports os
end

recommends "graphite"
suggests "iptables"

depends "runit"
depends "megam_preinstall"
