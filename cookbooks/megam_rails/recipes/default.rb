#
# Cookbook Name:: megam_rails_application
# Recipe:: application
#
# Copyright 2013, Devops Israel
#
# All rights reserved - Do Not Redistribute
#

#include_recipe "megam_ruby"

include_recipe "git"

file_name = File.basename(node['megam']['deps']['component']['inputs']['source'])
dir = File.basename(file_name, '.*')
node.set[:rails][:app][:name] = "#{dir}"
#=end

node.set[:rails][:app][:name] = "#{dir}"
node.set[:rails][:app][:path] = "/var/www/projects/#{node[:rails][:app][:name]}"
node.set[:rails][:database][:name] = node[:rails][:app][:name]
node.set[:rails][:database][:username] = node[:rails][:app][:name]


node.set['megam']['env']['home'] = "#{node['megam']['user']['home']}/#{dir}"
include_recipe "megam_environment"

node.set["gulp"]["remote_repo"] = node['megam']['deps']['component']['inputs']['source']
node.set["gulp"]["local_repo"] = "#{node[:rails][:app][:path]}/current"
node.set["gulp"]["builder"] = "megam_ruby_builder"
node.set["gulp"]["project_name"] = node[:rails][:app][:name]

node.set["gulp"]["email"] = "#{node['megam']['deps']['account']['email']}"
node.set["gulp"]["api_key"] = "#{node['megam']['deps']['account']['api_key']}"


bash "Clone ruby builder" do
cwd "#{node['megam']['user']['home']}/bin"
  user node["megam"]["default"]["user"]
  group node["megam"]["default"]["user"]
   code <<-EOH
  git clone https://github.com/indykish/megam_ruby_builder.git
  EOH
end

rsyslog_inputs=[]
rsyslog_inputs = node.default['rsyslog']['logs']
rsyslog_inputs.push("/var/log/nginx/access.log", "/var/log/nginx/error.log", "#{node["megam"]["tomcat"]["home"]}/logs/catalina.out", "/var/log/upstart/gulpd.log")
node.override['rsyslog']['logs']= rsyslog_inputs

node.set['heka']['logs']["#{node['megam']['deps']['component']['name']}"] = ["/var/log/nginx/access.log", "/var/log/nginx/error.log", "#{node["megam"]["tomcat"]["home"]}/logs/catalina.out", "/var/log/upstart/gulpd.log"]


if node[:rails][:app][:name].split(" ").count > 1
  Chef::Application.fatal!("Application name must be one word long !")
end


# create deploy user & group
user node[:rails][:owner] do
  action :create
  supports manage_home => true
end
group node[:rails][:group] do
  action :create
  members node[:rails][:owner]
end
directory File.join('/','home',node[:rails][:owner]) do
  owner node[:rails][:owner]
  group node[:rails][:group]
end
=begin
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
=end

application node[:rails][:app][:name] do
  action    node[:rails][:deploy][:action]
  path      node[:rails][:app][:path]

  if node[:rails][:deploy][:ssh_key]
    deploy_key node[:rails][:deploy][:ssh_key]
  end
  #repository        node[:rails][:deploy][:repository]
#Repository value is getting from s3 json
  repository        "#{node['megam']['deps']['component']['inputs']['source']}"
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
   # database_master_role   node[:rails][:deploy][:database_master_role]
   # database_template      node[:rails][:deploy][:database_template]
    gems                   node[:rails][:gems] | [ "bundler" ]
    # can't put node[:rails][...] things inside the database block
=begin
    database do
      adapter  db_adapter
      host     db_host
      database db_name
      username db_username
      password db_password
    end
=end
  end

  before_restart do
    execute "upstart-reload-configuration" do
      command "/sbin/initctl reload-configuration"
      action [:nothing]
    end

    # use upstart for unicorn
    template "/etc/init/#{node[:rails][:app][:service]}.conf" do
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

    service "#{node[:rails][:app][:service]}" do
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
      execute "sudo /sbin/start #{node[:rails][:app][:service]}"
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


gem_package "rake" do
  action :install
end

=begin
  execute "Gem install Rake" do
  cwd "#{node[:rails][:app][:path]}/current"  
  user "root"
  group "root"
  command "gem install rake"
  end
=end

  execute "Execute assets precompile" do
  cwd "#{node[:rails][:app][:path]}/current"  
  user "root"
  group "root"
  command "sudo bundle exec rake assets:precompile"
  end

#Megam change IF db
=begin
  execute "Execute assets precompile" do
  cwd "#{node[:rails][:app][:path]}/current"  
  user "root"
  group "root"
  command "sudo bundle exec rake db:migrate"
  end
=end

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
  command "sudo ./stop #{node[:rails][:app][:service]}"
  end

  execute "Execute unicorn start" do
  cwd "/sbin"  
  user "root"
  group "root"
  command "sudo ./start #{node[:rails][:app][:service]}"
  end

#include_recipe "megam_gulp"

