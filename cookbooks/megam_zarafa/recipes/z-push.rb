##CONFIGURE Z-PUSH############################################

#get and untar z-push
#template "/usr/share/z-push/config.php" => set timezone

#TODO verify and setup installation process
# TODO implement update process with notifies

major = "2.1"
minor = "2.1.0-1750"
ark "z-push" do
  url "http://zarafa-deutschland.de/z-push-download/final/#{major}/z-push-#{minor}.tar.gz"
  not_if { ::File.exist? "/usr/local/z-push" }
end

template "/usr/local/z-push/config.php" do
  notifies :restart, "service[zarafa-server]"
end

directory "/var/lib/z-push" do
  mode 0755
  owner "www-data"
  group "www-data"
end

directory "/var/log/z-push" do
  mode 0755
  owner "www-data"
  group "www-data"
end

template "/etc/apache2/conf.d/z-push" do
  notifies :reload, "service[apache2]"
end

