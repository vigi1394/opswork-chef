directory "/sendhub_keychain" do
    owner "ubuntu"
    group "ubuntu"
    action :create
end

directory "/sendhub_keychain/certs" do
    owner "ubuntu"
    group "ubuntu"
    action :create
end

execute 'retrieve-apns-cert' do
    command "aws --region us-east-1 s3 cp s3://sendhub-keychain/#{node[:sendhub][:apps][:apns][:apnsCert]} /sendhub_keychain/certs/. ; chmod 600 /sendhub_keychain/certs/#{node[:sendhub][:apps][:apns][:apnsCert]} ; chown ubuntu:ubuntu /sendhub_keychain/certs/#{node[:sendhub][:apps][:apns][:apnsCert]}"
end
