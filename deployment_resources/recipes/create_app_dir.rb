for layer in node[:opsworks][:instance][:layers] do
    directory "/#{node[:sendhub][:base]}/#{node[:sendhub][:layers][layer][:appName]}" do
        owner "ubuntu"
        group "ubuntu"
        action :create
    end
end
