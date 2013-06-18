#
# Cookbook Name:: megam_ciakka
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
default['akka']['home'] = "/home/ubuntu"
default['akka']['location']['deb'] = "/home/ubuntu/megamakka-0.12.3-build-0100.deb"
default['akka']['user'] = "ubuntu"
default['akka']['mode'] = "0755"

default['akka']['gulp']['conf'] = "/etc/init/gulp.conf"
default['akka']['gulp']['script'] = "/usr/local/share/megamakka/bin/start org.megam.akka.CloApp"
default['akka']['gulp']['port'] = "27020"

#Template file
default['akka']['template']['conf'] = "gulp.conf.erb"

#Shell Commands
default['akka']['deb'] = "https://s3-ap-southeast-1.amazonaws.com/megampub/debs/megamakka-0.12.3-build-0100.deb"
default['akka']['dpkg'] = "sudo dpkg -i megamakka-0.12.3-build-0100.deb"
default['akka']['start'] = "sudo start gulp"
