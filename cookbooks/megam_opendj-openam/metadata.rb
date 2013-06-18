name 		 "megam_opendj-openam"
maintainer       "Megam Syaytems"
maintainer_email "alrin@megam.co.in"
license          "Apache 2.0"
description      "Installs/Configures opendj"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.0"

depends "opendj-openam"

depends "megam_route53"

depends "megam_ciakka"

%w{ debian ubuntu }.each do |os|
  supports os
end

recipe "megam_opendj-openam::default", "Installs and configures OpenDJ"
