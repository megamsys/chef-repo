if platform?( "redhat", "centos", "fedora" )
  #package "apr-devel"
  #package "libconfuse-devel"
  #package "expat-devel"
  #package "pcre-devel"
  #package "rrdtool-devel"


bash "install Ganglia with python" do
 cwd "/tmp"
  user "root"
  group "root"
   code <<-EOH

   	wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/megampub/0.3/rpm/apr-1.3.9-1.x86_64.rpm
rpm -ivh apr-1.3.9-1.x86_64.rpm

wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/megampub/0.3/rpm/apr-devel-1.3.9-1.x86_64.rpm
rpm -ivh apr-devel-1.3.9-1.x86_64.rpm

wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/megampub/0.3/rpm/libconfuse-2.6-2.el6.rf.x86_64.rpm
rpm -ivh libconfuse-2.6-2.el6.rf.x86_64.rpm

wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/megampub/0.3/rpm/libganglia-3.6.0-1.x86_64.rpm
rpm -ivh libganglia-3.6.0-1.x86_64.rpm

wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/megampub/0.3/rpm/ganglia-gmond-3.6.0-1.x86_64.rpm
rpm -ivh ganglia-gmond-3.6.0-1.x86_64.rpm

wget --no-check-certificate https://s3-ap-southeast-1.amazonaws.com/megampub/0.3/rpm/ganglia-gmond-modules-python-3.6.0-1.x86_64.rpm
rpm -ivh ganglia-gmond-modules-python-3.6.0-1.x86_64.rpm
  EOH
end

end

=begin
bash "install Ganglia" do
  user "root"
  group "root"
   code <<-EOH
   	cd /usr/local/src/
  	wget http://sourceforge.net/projects/ganglia/files/ganglia%20monitoring%20core/3.6.0/ganglia-3.6.0.tar.gz
  	tar -xzvf ganglia-3.6.0.tar.gz
  	cd ganglia-3.6.0
  	./configure --with-libpcre=no --sysconfdir=/etc/ganglia
  	make
  	make install
  EOH
end


remote_file "/usr/src/ganglia-#{node[:ganglia][:version]}.tar.gz" do
  source node[:ganglia][:uri]
  #checksum node[:ganglia][:checksum]
end

src_path = "/usr/src/ganglia-#{node[:ganglia][:version]}"

execute "untar ganglia" do
  command "tar xzf ganglia-#{node[:ganglia][:version]}.tar.gz"
  creates src_path
  cwd "/usr/src"
end

execute "configure ganglia build" do
  command "./configure --with-gmetad --with-libpcre=no --sysconfdir=/etc/ganglia"
  creates "#{src_path}/config.log"
  cwd src_path
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
  to "/usr/local/src/ganglia-3.6.0"
  only_if do
    node[:kernel][:machine] == "x86_64" and
      platform?( "redhat", "centos", "fedora" )
  end
end
=end
