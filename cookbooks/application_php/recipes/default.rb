application "my-app" do
  path "/var/www/html"
  owner "root"
  group "root"
  repository "#{node['scm']}"
  deploy_key "megam"
  #revision "#{node['scm_branch']}"
  packages ["php-soap"]

  php do
   database_master_role "database_master"
   local_settings_file "php.conf"
  end
 mod_php_apache2
end

node.set[:build][:localrepo]='/var/www/html/current'

node.set["megam"]["github"]["ci"] = "false"

execute "Clone builder script " do
  cwd "#{node['megam']['env']['home']}/gulp"
  command "git clone https://github.com/megamsys/buildpacks.git"
end

execute "chmod to execute build " do
  cwd "#{node['megam']['env']['home']}/gulp/buildpacks/php/"
  command "chmod 755 build"
end

execute "Start build script #{`pwd`}" do
  cwd "#{node['megam']['env']['home']}/gulp/buildpacks/php/"
  command "./build remote_repo=#{node['megam_scm']} build_ci=#{node['megam']['github']['ci']} megam_home=#{node['megam']['env']['home']}/gulp local_repo=#{node.set[:build][:localrepo]}"
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
