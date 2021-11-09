service "rsyslog" do
    supports :restart => true, :status =>true, :reload => true
    init_command 'service rsyslog'
    action :nothing
end

template "/etc/rsyslog.conf" do
    source "rsyslog.client.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, "service[rsyslog]"
end

execute "echo 'checking if rsyslog is not running - if so start it'" do
    not_if "pgrep rsyslog"
    notifies :start, "service[rsyslog]"
end
