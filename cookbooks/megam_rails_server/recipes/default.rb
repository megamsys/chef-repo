#
# Cookbook Name:: megam_rails_application
# Recipe:: application
#
# Copyright 2013, Devops Israel
#
# All rights reserved - Do Not Redistribute
#

include_recipe "megam_ruby" #installs ruby2.0-p353

include_recipe "megam_sandbox"

include_recipe "apt"

package "libpq-dev" do
  action :install
end

package "wamerican" do
  action :install
end

package "wbritish" do
  action :install
end


if node[:rails][:app][:name].split(" ").count > 1
  Chef::Application.fatal!("Application name must be one word long !")
end
include_recipe "git" # install git, no support for svn for now

#Cookbook to parse the json which is in s3. Json contains the cookbook dependencies.
#include_recipe "megam_deps"

#include_recipe "megam_ciakka"
#node.set[:ganglia][:hostname] = "#{node.name}.#{node["myroute53"]["zone"]}"
#include_recipe "megam_ganglia::nginx"

# create deploy user & group
user node[:rails][:owner] do
  action :create
  supports manage_home => true
  shell "/bin/bash"
end
group node[:rails][:group] do
  action :create
  members node[:rails][:owner]
end
directory File.join('/','home',node[:rails][:owner]) do
  owner node[:rails][:owner]
  group node[:rails][:group]
end
#=begin
# save generated or provided database password in the node itself
node.set[:rails][:database][:password] = node[:rails][:database][:password]
node.set[:rails][:database][:username] = node[:rails][:database][:username]
node.set[:rails][:database][:name] = node[:rails][:database][:name]

# can't put node[:rails][...] things inside the database block

db_host     = node[:rails][:database][:host]
db_name     = node[:rails][:database][:name]
db_username = node[:rails][:database][:username]
db_password = node[:rails][:database][:password]
db_adapter  = node[:rails][:database][:adapter]
#=end

old_home = ENV['HOME']
ruby_block "clear_home for CHEF-3940" do
  block do
    ENV['HOME'] = Etc.getpwnam("#{node[:rails][:owner]}").dir
  end
  not_if {`git --version`.split[2].to_f <= 1.7}
end



application node[:rails][:app][:name] do
  action    node[:rails][:deploy][:action]
  path      node[:rails][:app][:path]

  if node[:rails][:deploy][:ssh_key]
    deploy_key node[:rails][:deploy][:ssh_key]
  end
  repository        node[:rails][:deploy][:repository]
#Repository value is getting from s3 json
  #repository        "#{node["megam_deps"]["predefs"]["scm"]}"
  revision          node[:rails][:deploy][:revision]
  enable_submodules node[:rails][:deploy][:enable_submodules]
  shallow_clone     node[:rails][:deploy][:shallow_clone]

  environment_name node[:rails][:app][:environment]

  packages   node[:rails][:packages]
  owner      node[:rails][:owner]
  group      node[:rails][:group]

  # symlink/remove/create various things during deploys
  purge_before_symlink       node[:rails][:deploy][:purge_before_symlink]
  create_dirs_before_symlink node[:rails][:deploy][:create_dirs_before_symlink]
  symlinks                   node[:rails][:deploy][:symlinks]
  symlink_before_migrate     node[:rails][:deploy][:symlink_before_migrate]

  # useful commands
  migrate           node[:rails][:deploy][:migrate]
  migration_command node[:rails][:deploy][:migration_command]
  restart_command   node[:rails][:deploy][:restart_command]

  rails do
    bundler                node[:rails][:deploy][:bundler]
    bundle_command         node[:rails][:deploy][:bundle_command]
    bundler_deployment     node[:rails][:deploy][:bundler_deployment]
    bundler_without_groups node[:rails][:deploy][:bundler_without_groups]
    precompile_assets      node[:rails][:deploy][:precompile_assets]
    database_master_role   node[:rails][:deploy][:database_master_role]
    database_template      node[:rails][:deploy][:database_template]
    gems                   node[:rails][:gems] | [ "bundler" ]
    # can't put node[:rails][...] things inside the database block
#=begin
    database do
      adapter  db_adapter
      host     db_host
      database db_name
      username db_username
      password db_password
    end
#=end
  end

  before_restart do
    execute "upstart-reload-configuration" do
      command "/sbin/initctl reload-configuration"
      action [:nothing]
    end

    # use upstart for unicorn
    template "/etc/init/unicorn_#{node[:rails][:app][:name]}.conf" do
      mode 0644
      cookbook cookbook_name
      source "unicorn.conf.erb"
      owner "root"
      group "root"
      notifies :run, "execute[upstart-reload-configuration]", :immediately
      variables(
        app_name:         node[:rails][:app][:name],
        app_path:         File.join(node[:rails][:app][:path], "current"),
        rails_env:        node[:rails][:app][:environment],
        nginx_user:       node[:nginx][:user],
        nginx_group:      node[:nginx][:group],
        socket:           node[:rails][:unicorn][:port],
        bundler:          node[:rails][:unicorn][:bundler],
        bundle_command:   node[:rails][:unicorn][:bundle_command]
      )
    end

    service "unicorn_#{node[:rails][:app][:name]}" do
      provider Chef::Provider::Service::Upstart
      supports status: true, restart: true
      action :nothing
    end
  end

  unicorn do
    worker_processes node[:rails][:unicorn][:worker_processes]
    worker_timeout   node[:rails][:unicorn][:worker_timeout]
    preload_app      node[:rails][:unicorn][:preload_app]
    before_fork      node[:rails][:unicorn][:before_fork]
    port             node[:rails][:unicorn][:port]
    bundler          node[:rails][:unicorn][:bundler]
    bundle_command   node[:rails][:unicorn][:bundle_command]
    restart_command  do  # when a string is used, it will run it as owner/group not as root!
      execute "sudo /sbin/start unicorn_#{node[:rails][:app][:name]}"
    end
    forked_user      node[:rails][:owner]
    forked_group     node[:rails][:group]
  end

  nginx_load_balancer do
    #### defaults ###
    template            node[:rails][:nginx][:template]
    server_name         node[:rails][:nginx][:server_name]
    port                node[:rails][:nginx][:port]
    application_port    node[:rails][:nginx][:application_port]
    static_files        node[:rails][:nginx][:static_files]   # eg. { "/img" => "images" }
    ssl                 node[:rails][:nginx][:ssl]
    ssl_certificate     node[:rails][:nginx][:ssl_certificate]
    ssl_certificate_key node[:rails][:nginx][:ssl_certificate_key]
  end
end


ruby_block "reset_home" do
  block do
    ENV['HOME'] = old_home
  end
  not_if {`git --version`.split[2].to_f <= 1.7}
end

gem_package "rake" do
  action :install
end

bash "---> ADD ENV variables " do
  user node[:rails][:owner]
  group node[:rails][:group]
  code <<-EOH
  echo 'export FACEBOOK_CLIENT_ID=656642044368521' >> /home/#{node[:rails][:owner]}/.bashrc
  echo 'export FACEBOOK_SECRET_KEY=0fb6a80893cdb88fdc2b2c021b454977' >> /home/#{node[:rails][:owner]}/.bashrc  
  echo 'export TWITTER_CLIENT_ID=RXzRHtYF4cYiVKhD0kmBg' >> /home/#{node[:rails][:owner]}/.bashrc
  echo 'export TWITTER_SECRET_KEY=hLPGq2f7Z6BoXN8I5USYYvGQyZtMMbl8FIhG49VY8Os' >> /home/#{node[:rails][:owner]}/.bashrc
  echo 'export GOOGLE_CLIENT_ID=1086028648606.apps.googleusercontent.com' >> /home/#{node[:rails][:owner]}/.bashrc
  echo 'export GOOGLE_SECRET_KEY=2rUaVHUCbu9CZClosVMJsrEv' >> /home/#{node[:rails][:owner]}/.bashrc
  echo 'export POSTGRES_DB=cocdb' >> /home/#{node[:rails][:owner]}/.bashrc
  echo 'export POSTGRES_USER=megam' >> /home/#{node[:rails][:owner]}/.bashrc
  echo 'export POSTGRES_PW=team4megam' >> /home/#{node[:rails][:owner]}/.bashrc
  echo 'export SUPPORT_EMAIL=support@megam.co.in' >> /home/#{node[:rails][:owner]}/.bashrc  
  echo 'export SUPPORT_PASSWORD=team4megam' >> /home/#{node[:rails][:owner]}/.bashrc 
  source /home/#{node[:rails][:owner]}/.bashrc 
  EOH
end

  execute "Execute DB migrate" do
  cwd "#{node[:rails][:app][:path]}/current"  
  user "root"
  group "root"
  command "sudo rake db:migrate RAILS_ENV=production"
  end
  
  execute "Execute DB seed" do
  cwd "#{node[:rails][:app][:path]}/current"  
  user "root"
  group "root"
  command "sudo rake db:seed RAILS_ENV=production"
  end

  execute "Execute assets precompile" do
  cwd "#{node[:rails][:app][:path]}/current"  
  user "root"
  group "root"
  command "sudo rake assets:precompile RAILS_ENV=production"
  end

  execute "Execute change owner" do
  cwd "#{node[:rails][:app][:path]}/current/"  
  user "root"
  group "root"
  command "sudo chown -R #{node[:rails][:owner]}:#{node[:rails][:group]} tmp"
  end

  execute "Execute unicorn stop" do
  cwd "/sbin"  
  user "root"
  group "root"
  command "sudo ./stop unicorn_#{node[:rails][:app][:name]}"
  end

  execute "Execute unicorn start" do
  cwd "/sbin"  
  user "root"
  group "root"
  command "sudo ./start unicorn_#{node[:rails][:app][:name]}"
  end


