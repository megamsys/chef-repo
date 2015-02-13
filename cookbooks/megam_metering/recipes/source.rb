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

   	yum -y install apr-devel apr-util check-devel cairo-devel pango-devel libxml2-devel rpmbuild glib2-devel \
   dbus-devel freetype-devel fontconfig-devel gcc-c++ expat-devel python-devel libXrender-devel pcre-devel
        cd /tmp
        wget http://savannah.nongnu.org/download/confuse/confuse-2.7.tar.gz
        tar -xzvf confuse-2.7.tar.gz
         cd confuse-2.7
        export CFLAGS="-g  -g -O2 -fno-strict-aliasing -Wall -D_REENTRANT -fPIC"
        ./configure --enable-shared
make
make install

echo "/usr/local/lib" > /etc/ld.so.conf

ldconfig

#just store it under ganglia-3.6.1, this wget stores in a long name.
wget -O ganglia.tar.gz http://downloads.sourceforge.net/project/ganglia/ganglia%20monitoring%20core/3.6.1/ganglia-3.6.1.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fganglia%2Ffiles%2Fganglia%2520monitoring%2520core%2F&ts=1417064329&use_mirror=softlayer-sng 

cd ganglia-3.6.1
./configure --with-libconfuse=/usr/local/lib
make
make install


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
