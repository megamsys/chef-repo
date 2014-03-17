gem_package "fog" do
  action :install
end

include_recipe "megam_drbd::s3"

ruby_block "Add volume" do
  block do
   require 'fog'
   
       case node["megam_deps"]["request"]["command"]["compute"]["access"]["zone"]
        when 'az3'
          hp_avl_zone = 'az-3.region-a.geo-1'
        when 'az2'
          hp_avl_zone = 'az-2.region-a.geo-1'
        else
          hp_avl_zone = 'az-1.region-a.geo-1'
        end
        
   	    hp_access_key = "#{node["megam_node"]["access_key"]}"
            hp_secret_key = "#{node["megam_node"]["secret_key"]}"
            hp_tenant_id = "#{node["megam_deps"]["request"]["command"]["compute"]["cc"]["tenant_id"]}"
            hp_auth_uri = "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/"
            #hp_avl_zone = "az-2.region-a.geo-1"
            
   ser = Fog::Compute.new(
            :provider => 'HP',
            :hp_access_key => hp_access_key,
            :hp_secret_key => hp_secret_key,
            :hp_tenant_id => hp_tenant_id,
            :hp_auth_uri => hp_auth_uri,
            :hp_avl_zone => hp_avl_zone
            )
            
            ser.servers.all.each do |s|
        	if ser.name.to_s == "#{node.name}"
        		instance_id = s.id
		end
	    end
	    
  
	vol = Fog::HP::BlockStorage.new(
            :hp_access_key => hp_access_key,
            :hp_secret_key => hp_secret_key,
            :hp_tenant_id => hp_tenant_id,
            :hp_auth_uri => hp_auth_uri,
            :hp_avl_zone => hp_avl_zone
            )
            new_volume = vol.volumes.create(
   :name => "vol_#{instance_id}",
   :description => "Megam Test Volume",
   :size => 1)
    # Attach volume to an existing server with id 1234
    new_volume.attach(instance_id, "/dev/sdf")
    
  end
end

        
