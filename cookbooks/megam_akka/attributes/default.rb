#
# Cookbook Name:: megam_akka
# Attributes:: akka
#
# Copyright 2010-2012, Promet Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#Remote Locations
default['akka']['mode'] = "0755"

default['akka']['init']['conf'] = "/etc/init/akka.conf"

#Command
default['akka']['start'] = "start akka"
default['akka']['script']['cmd'] = "/usr/share/megamherk/bin/start org.megam.akka.CloApp"
default['akka']['script']['port'] = "27020"


if node['megam_version']
default['akka']['deb'] = "https://s3-ap-southeast-1.amazonaws.com/megampub/#{node['megam_version']}/debs/megamherk.deb"
else
default['akka']['deb'] = "https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/debs/megamherk.deb"
end
default['akka']['dpkg'] = "dpkg -i megamherk.deb"

#Template File
default['akka']['template']['conf'] = "akka.conf.erb"

#script file location
default['akka']['init']['script'] = "/usr/share/megamherk/bin/start org.megam.akka.CloApp"

default["akka"]["dir"]["script"] = "/usr/share/megamherk/bin/"
default["akka"]["file"]["script"] = "start"

default["akka"]["sbt"]["jar"] = "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.0/sbt-launch.jar"




