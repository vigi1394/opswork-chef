include_recipe "deployment_resources::logstash_forwarder_service"

execute 'download_logstash_forwarder_deb' do
  command "aws --region us-east-1 s3 cp s3://sendhub-deploy/logstash-forwarder/logstash-forwarder_0.4.0_amd64.deb /home/ubuntu/logstash-forwarder_0.4.0_amd64.deb"
  creates "/home/ubuntu/logstash-forwarder_0.4.0_amd64.deb"
end

dpkg_package "logstash-forwarder" do
  source "/home/ubuntu/logstash-forwarder_0.4.0_amd64.deb"
  action :install
end

template "/etc/logstash-forwarder.conf" do
  source "logstash-forwarder.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/etc/sysconfig" do
  owner "root"
  group "root"
  mode 0755
  action :create
end

template "/etc/sysconfig/logstash-forwarder" do
  source "sysconfig_logstash-forwarder.erb"
  owner "root"
  group "root"
  mode 0644
end

execute 'acquire_logstash_key' do
  command "aws --region us-east-1 s3 cp s3://sendhub-keychain/logstash-forwarder-prod.crt /etc/ssl/certs/. ; chmod 644 /etc/ssl/certs/logstash-forwarder-prod.crt ; chown root:root /etc/ssl/certs/logstash-forwarder-prod.crt"
  creates "/etc/ssl/certs/logstash-forwarder-prod.crt"
  notifies :restart, "service[logstash-forwarder]"
end

execute "echo 'checking if logstash-forwarder is not running - if so start it'" do
  not_if "pgrep logstash-forwarder"
  notifies :start, "service[logstash-forwarder]"
end