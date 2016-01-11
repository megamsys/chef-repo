package 'build-essential' do  
  action :nothing
end.run_action(:install)

xsltdev = package "libxslt-dev" do
   action :nothing
end
 
xmldev = package "libxml2-dev" do
   action :nothing
end
 
xsltdev.run_action(:install)
xmldev.run_action(:install)
 
chef_gem "fog"
chef_gem "excon"

#gem_package "fog"

include_recipe "megam_drbd::s3"

ruby_block "Add volume" do
  block do
   require 'fog'
   
       case node["megam_route"]["request"]["command"]["compute"]["access"]["zone"]
        when 'az3'
          hp_avl_zone = "az-3.region-a.geo-1"
        when 'az2'
          hp_avl_zone = "az-2.region-a.geo-1"
        else
          hp_avl_zone = "az-1.region-a.geo-1"
        end
        
   	    hp_access_key = "#{node["megam_node"]["access_key"]}".strip
            hp_secret_key = "#{node["megam_node"]["secret_key"]}".strip
            hp_tenant_id = "#{node["megam_route"]["request"]["command"]["compute"]["cc"]["tenant_id"]}".strip
            hp_auth_uri = "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/".strip
            #hp_avl_zone = "az-2.region-a.geo-1"

   ser = Fog::Compute.new(
            :provider => "HP",
            :version => :v2,
            :hp_access_key => "#{hp_access_key}",
            :hp_secret_key => "#{hp_secret_key}",
            :hp_tenant_id => "#{hp_tenant_id}",
            :hp_auth_uri => "#{hp_auth_uri}",
            :hp_avl_zone => "#{hp_avl_zone}"
             )
            
            ser.servers.all.each do |s|
        	if s.name.to_s == "#{node.name}"
        		@instance_id = s.id
		end
	    end
	vol = Fog::HP::BlockStorage.new(
	    :version => :v2,
            :hp_access_key => "#{hp_access_key}",
            :hp_secret_key => "#{hp_secret_key}",
            :hp_tenant_id => "#{hp_tenant_id}",
            :hp_auth_uri => "#{hp_auth_uri}",
            :hp_avl_zone => "#{hp_avl_zone}"
            )
            new_volume = vol.volumes.create(
   :name => "vol_#{@instance_id}",
   :description => "Megam Test Volume",
   :size => 1)
   until (vol.volumes.get(new_volume.id).status == "available")
   puts "."
  	sleep(1)
   end

    # Attach volume to an existing server with id 1234
    new_volume.attach(@instance_id, "/dev/sdf")
    
  end
end

        
