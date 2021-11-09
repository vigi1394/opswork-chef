execute 'service_deployments' do
    command "echo 'source /deploy/hydra/venv/bin/activate; export HOME='/home/ubuntu' ; cd /deploy/hydra; fab -u #{node[:sendhub][:sshUser]} -i /home/ubuntu/.ssh/#{node[:sendhub][:sshIdentity]} handleProvisionRequests &> /logs/service_provision_requests_#{Time.now.to_i}_#{Process.pid}.log' | /bin/bash"
    action :run
end
