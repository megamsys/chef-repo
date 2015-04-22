 service 'nginx' do
    supports :status => true, :restart => true, :reload => true
    action   :nothing
 end

 service 'ghost' do
    supports :status => true, :restart => true, :reload => true, :start => true, :stop => true
    action   :nothing
 end
