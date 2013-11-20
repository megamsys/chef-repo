# Installs redis from packages

execute "install ppa for redis-server" do
  cwd "/home/ubuntu"
  user "root"
  group "root"
   command "sudo add-apt-repository ppa:chris-lea/redis-server"
end

execute "sudo apt-get update " do
  cwd "/home/ubuntu"
  user "root"
  group "root"
  command "sudo apt-get update "
end

pkg = value_for_platform( [:ubuntu, :debian] => {:default => "redis-server"},
                         [:centos, :redhat] => {:default => "redis"},
                         :default => "redis")
package pkg
node.normal["redis2"]["daemon"] = "/usr/bin/redis-server"

