include_recipe "deployment_resources::logstash_forwarder_service"

template "/etc/logstash-forwarder.conf" do
  source "logstash-forwarder.conf.erb"
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