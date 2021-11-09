package 'nginx' do
    action :install
end

include_recipe 'sh_nginx::configure'
