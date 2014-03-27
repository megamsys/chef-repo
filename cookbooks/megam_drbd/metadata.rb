name              "megam_drbd"
maintainer        "Megam Systems"
maintainer_email  "alrin@megam.co.in"
license           "Apache 2.0"
description       "Installs/Configures drbd."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.8.2"
depends           "apt"

%w{ debian ubuntu }.each do |os|
  supports os
end


