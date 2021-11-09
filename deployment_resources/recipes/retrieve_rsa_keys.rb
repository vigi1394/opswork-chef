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

for layer in node[:opsworks][:instance][:layers] do
  for key in node[:sendhub][:apps][node[:sendhub][:layers][layer][:appName]][:keys] do
    execute "retrieve-#{key}" do
      command "aws --region us-east-1 s3 cp s3://sendhub-keychain/#{key} /sendhub_keychain/certs/. ; chmod 600 /sendhub_keychain/certs/#{key} ; chown ubuntu:ubuntu /sendhub_keychain/certs/#{key}"
    end
  end
end