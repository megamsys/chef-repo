define :call do

#============================================Component Recipe ====================================================
ckbk = "#{node['tosca_type']}"

case ckbk                                                       #Case cookbook start
when "java"
        include_recipe "megam_java"
        include_recipe "megam_tomcat"                           #assumption
        include_recipe "megam_nginx"                           #assumption
when "docker"
        include_recipe "megam_docker"
when "hadoop"
        include_recipe "megam_analytics"
when "akka"
        include_recipe "megam_akka"
when "play"
        include_recipe "megam_play"
when "rails"
        include_recipe "megam_rails"
when "nodejs"
        include_recipe "megam_nodejs"
        include_recipe "megam_start"
when "riak"
        include_recipe "megam_riak"
when "redis"
        include_recipe "megam_redis2::master"
when "postgresql"
        include_recipe "megam_postgresql::server"
when "wordpress"
        include_recipe "megam_wordpress"
when "op5"
        include_recipe "megam_op5"
when "rabbitmq"
        include_recipe "megam_rabbitmq"
when "zarafa"
        include_recipe "megam_zarafa"
else
        puts "Not a valid Tosca type"
end                                                             #case cookbook end



end
