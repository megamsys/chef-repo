# This recipe is for compiling redis from source.
#
#
include_recipe "build-essential"

node.default["redis2"]["daemon"] = "/usr/local/bin/redis-server"

ark "redis" do
  url node["redis2"]["source"]["url"]
  checksum node["redis2"]["source"]["checksum"]
  version node["redis2"]["source"]["version"]
  prefix_root "/usr/local/src"
  prefix_home "/usr/local/src"
  action :install_with_make
end

node.default["redis2"]["version"] = node["redis2"]["source"]["version"]
