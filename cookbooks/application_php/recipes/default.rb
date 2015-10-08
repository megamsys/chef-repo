puts "===================="
puts "php testing"
puts "+++++++++++++++++++++"

  application "my-app" do
  path "/var/www/html"
  owner "root"
  group "root"
  #owner node[:apache][:user]
  #group node[:apache][:user]  
  repository "https://github.com/awslabs/opsworks-demo-php-simple-app.git"
  deploy_key "xyz"
  revision "version1"
  packages ["php-soap"]

  php do
   database_master_role "database_master"
   local_settings_file "php.conf"
  end

 mod_php_apache2
end


#application "my-app" do
 # path "/usr/local/my-app"
  #repository "https://github.com/awslabs/opsworks-demo-php-simple-app.git"

#php do
 #   database_master_role "database_master"
   # database do
  #    database 'name'
  #    quorum 2
   #   replicas %w[Huey Dewey Louie]
   # end
 # end
#end

