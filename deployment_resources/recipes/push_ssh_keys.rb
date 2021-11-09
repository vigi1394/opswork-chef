execute "copyKeys_to_#{node[:sendhub][:sshIdentityDestIp]}" do
    command "scp -i /home/ubuntu/.ssh/#{node[:sendhub][:sshIdentity]} -o 'StrictHostKeyChecking no' -o 'BatchMode yes' /home/ubuntu/.ssh/#{node[:sendhub][:sshIdentity]} #{node[:sendhub][:sshUser]}@#{node[:sendhub][:sshIdentityDestIp]}:.ssh/."
end
