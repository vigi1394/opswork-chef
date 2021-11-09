include_recipe 'sh_nginx::service'

template "/etc/nginx/nginx.conf" do
    source "nginx.conf.erb"
    owner "root"
    group "root"
    mode 0644
end

template "/etc/nginx/conf.d/sendhub.conf" do
    source "sendhub.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :reload, "service[nginx]"
end

execute "echo 'checking if Nginx is not running - if so start it'" do
    not_if "pgrep nginx"
    notifies :start, "service[nginx]"
end
