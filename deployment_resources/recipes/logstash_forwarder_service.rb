service "logstash-forwarder" do
  supports :restart => true, :status => true
  action :nothing
end