remote_file "/usr/src/ganglia-#{node[:ganglia][:version]}.tar.gz" do
  source node[:ganglia][:uri]
  checksum node[:ganglia][:checksum]
end

src_path = "/usr/src/ganglia-#{node[:ganglia][:version]}"

execute "untar ganglia" do
  command "tar xzf ganglia-#{node[:ganglia][:version]}.tar.gz"
  creates src_path
  cwd "/usr/src"
end

template "/home/ubuntu/install.sh" do
  source "install.sh"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

execute "Install Dependencies " do
  cwd "/home/ubuntu"
  user "ubuntu"
  group "ubuntu"
  command "/home/ubuntu/install.sh"
end

template "/home/ubuntu/python3" do
  source "python3-change"
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

execute "Change python default to python3 " do
  cwd "/home/ubuntu"
  user "ubuntu"
  group "ubuntu"
  command "./python3"
end

if node[:ganglia][:gmetad]
  execute "configure ganglia build" do
    command "./configure --with-gmetad --with-python=/usr/bin/python3 --with-libpcre=yes --sysconfdir=/etc/ganglia"
    creates "#{src_path}/config.log"
    cwd src_path
  end

else

  execute "configure ganglia build" do
    command "./configure --with-python=/usr/bin/python3 --with-libpcre=yes --sysconfdir=/etc/ganglia"
    creates "#{src_path}/config.log"
    cwd src_path
  end

end

execute "build ganglia" do
  command "make"
  creates "#{src_path}/gmond/gmond"
  cwd src_path
end

execute "install ganglia" do
  command "make install"
  creates "/usr/sbin/gmond"
  cwd src_path
end

link "/usr/lib/ganglia" do
  to "/usr/lib64/ganglia"
  only_if do
    node[:kernel][:machine] == "x86_64" and
    platform?( "redhat", "centos", "fedora" )
  end
end
