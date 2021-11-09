service 'riak' do
    supports :restart => true, :status => true, :reload => true
    reload_command 'ulimit -n 65536 ; service riak reload'
    restart_command 'ulimit -n 65536 ; service riak restart'
    start_command 'ulimit -n 65536 ; service riak start'
    status_command 'ulimit -n 65536 ; service riak status'
    action :nothing
end
