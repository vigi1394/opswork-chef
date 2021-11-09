for layer in node[:opsworks][:instance][:layers] do
    execute "trigger_deployment_of_#{node[:sendhub][:layers][layer][:appName]}_on_#{node[:ipaddress]}" do
        command "ssh -i /home/ubuntu/.ssh/provision.pem -o 'StrictHostKeyChecking no' -o 'BatchMode yes' alfred@#{node[:sendhub][:deployServer]} 'mkdir -p /provision/#{node[:sendhub][:layers][layer][:appName]}/#{node[:sendhub][:layers][layer][:services].join(',')} ; echo #{node[:opsworks][:instance][:aws_instance_id]}####{node[:opsworks][:instance][:aws_instance_id]} > /provision/#{node[:sendhub][:layers][layer][:appName]}/#{node[:sendhub][:layers][layer][:services].join(',')}/#{node[:opsworks][:instance][:aws_instance_id]}.request'"
        action :run
    end
end
