name             "tomcat-openam"
maintainer       "Megam Systems"
maintainer_email "alrin@megam.co.in"
license          "Apache 2.0"
description      "Installs/Configures tomcat7 and OpenAM"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%w{ debian ubuntu }.each do |os|
  supports os
end

recipe "tomcat-openam::full_stack", "Installs and configures Tomcat, OpenDJ and OpenAM In a single instance"
recipe "tomcat-openam::vanilla", "Installs Tomcat and OpenAM. But Configures only tomcat"
recipe "tomcat-openam::configure", "Configures OpenAM" #It needs a dns of an instance which is running opendj

