name             "megam_tomcat-openam"
maintainer       "Megam Systems"
maintainer_email "alrin@megam.co.in"
license          "Apache 2.0"
description      "Installs/Configures tomcat7 and OpenAM"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%w{ megam_route53 megam_ciakka tomcat-openam logstash apt}.each do |cb|
  depends cb
end

%w{ debian ubuntu }.each do |os|
  supports os
end

recipe "megam_tomcat-openam::default", "Installs and configures Tomcat, OpenDJ and OpenAM In a single instance with route53"


