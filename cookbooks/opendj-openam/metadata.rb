name 		 "opendj-openam"
maintainer       "Megam Syaytems"
maintainer_email "thomasalrin@megam.io"
license          "Apache 2.0"
description      "Installs/Configures opendj"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.0"

depends "apt"

%w{ debian ubuntu }.each do |os|
  supports os
end

recipe "opendj-openam::single_instance", "Installs and configures OpenDJ"
