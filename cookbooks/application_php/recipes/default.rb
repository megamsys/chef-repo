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
node.set["megam"]["build"]["app"]="#{node['megam']['env']['home']}/gulp/buildpacks/php/"

if  !(File.file?("#{node['megam']['app']['home']}/build"))
  node.set["megam"]["github"]["ci"] = "false"
  execute "Clone builder script " do
    cwd "#{node['megam']['env']['home']}/gulp"
    command "git clone https://github.com/megamsys/buildpacks.git"
  end

  execute "chmod to execute build " do
    cwd node["megam"]["build"]["app"]
    command "chmod 755 build"
  end

execute "chmod to execute build " do
  cwd "#{node['megam']['build']['app']}"
  command "(echo 4a; echo \"remote_repo=#{node['megam_scm']} \"; echo .; echo w) | ed - build"
end
  execute "Start build script #{`pwd`}" do
    cwd node["megam"]["build"]["app"]
    command "./build  build_ci=#{node['megam']['github']['ci']}"
  end
else
  execute "chmod to execute local build " do
    cwd "#{node['megam']['app']['home']}"
    command "chmod 755 build"
  end
  execute "Copy builder script " do
    cwd node['megam']['app']['home']
    command "cp ./build #{node['megam']['env']['home']}/gulp"
  end
  execute "Own builder script " do
    cwd node['megam']['app']['home']
    command "./build"
  end
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
