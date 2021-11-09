directory "/#{node[:sendhub][:base]}" do
    owner "ubuntu"
    group "ubuntu"
    action :create
end

