=begin
//client connect with remote chef
Vagrant.configure("2") do |config|
  
 config.vm.box =  "precise64"
config.vm.provision :chef_client do |chef|
    chef.chef_server_url = "https://chef.megam.co.in/cookbooks"
    chef.validation_key_path = "chef-validator.pem"
    chef.client_key_path ="subash.pem"
    chef.add_recipe "apache2"
  end
end

=end

Vagrant::Config.run do |config|
    
    config.vm.box =  "precise64"
    #config.vm.box =  "raring-amd64"
    config.vm.box_url = "http://cloud-images.ubuntu.com/raring/current/raring-server-cloudimg-vagrant-amd64-disk1.box"
    config.vm.network :forwarded_port, guest: 80, host: 8888
    config.vm.provision :shell, :inline => "gem install chef --version 11.4.2 --no-rdoc --no-ri --conservative"

    config.vm.provision :chef_solo do |chef|
    chef.add_recipe "apt"
    chef.add_recipe "nginx"
        
       
    end
end


