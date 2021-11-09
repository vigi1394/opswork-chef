directory "/var/log/hosts" do
    owner "syslog"
    group "adm"
    mode 0750
    action:create
end

directory "/etc/rsyslog.d/keys/ca.d" do
    owner "root"
    group "root"
    mode 0777
    recursive true
    action :create
end

execute "curl https://logdog.loggly.com/media/logs-01.loggly.com_sha12.crt > logs-01.loggly.com_sha12.crt" do
    cwd "/etc/rsyslog.d/keys/ca.d"
    user "root"
    creates "/etc/rsyslog.d/keys/ca.d/logs-01.loggly.com_sha12.crt"
end

service "rsyslog" do
    supports :restart => true, :status => true, :reload => true
    init_command 'service rsyslog'
    action :nothing
end

template "/etc/logrotate.d/sendhub" do
    source "sendhub_logrotate.conf.erb"
    owner "root"
    group "root"
    mode 0644
end

template "/etc/rsyslog.conf" do
    source "rsyslog.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, "service[rsyslog]"
end

execute "echo 'checking if rsyslog is not running - if so start it'" do
    not_if "pgrep rsyslog"
    notifies :start, "service[rsyslog]"
end
