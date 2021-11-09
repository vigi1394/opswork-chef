template "/etc/cloudwatch.conf" do
    source "cloudwatch.conf.erb"
    owner "root"
    group "root"
    mode 0644
    action :create
end

execute 'enable_cloudwatch' do
  command 'curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O; chmod +x ./awslogs-agent-setup.py; ./awslogs-agent-setup.py -n -r us-east-1 -c /etc/cloudwatch.conf'
end
