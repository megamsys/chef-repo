define :call do


#============================================Component Recipe ====================================================
ckbk = "#{node['megam']['deps']['component']['tosca_type']}".split('.').last

case ckbk                                                       #Case cookbook start
when "java"
        include_recipe "megam_java"
        include_recipe "megam_tomcat"                           #assumption
        include_recipe "megam_nginx"                           #assumption
when "sqlite"
        include_recipe "megam_sqlite3"
when "docker"
        include_recipe "megam_docker"
when "hadoop"
        include_recipe "megam_analytics"
when "sqlite3"
        include_recipe "megam_sqlite3"
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


#============================================Component Additional Recipe (Tomcat, Nginx etc)=====================================

add_ckbk = node['megam']['deps']['component']['requirements']['additional']

unless add_ckbk.nil? || add_ckbk.empty?

add_ckbk.each do |ad_ckbk|                      #For each additional cookbook start
case ad_ckbk                                                       #Case additional cookbook start
when "tomcat"
        include_recipe "megam_tomcat"
#when "jetty"
        #include_recipe "megam_jetty"
#when "jboss"
#        include_recipe "megam_jboss"
when "nginx"
        include_recipe "megam_nginx"
end                                                             #Case additional cookbook end
end                                                             #For each additional cookbook end

end                                                             #end unless

end
