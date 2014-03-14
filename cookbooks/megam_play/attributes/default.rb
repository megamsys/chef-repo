

#AWS public DNS
#default["host"]["dns"] = "#{node[:ec2][:public_hostname]}"

if node['megam_version']
	default["play"]["deb"] = "https://s3-ap-southeast-1.amazonaws.com/megampub/#{node["megam_version"]}/debs/megamplay.deb"
else
	default["play"]["deb"] = "https://s3-ap-southeast-1.amazonaws.com/megampub/0.1/debs/megamplay.deb"
end


default["play"]["dir"]["script"] = "/usr/share/megamplay/bin/"
default["play"]["file"]["script"] = "megamplay"

default["play"]["sbt"]["jar"] = "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.0/sbt-launch.jar"

default['play']['dir'] = "play-dir"
