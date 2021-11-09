include_recipe 'sh_riak::service'

#### Configure System ####

execute 'raise file limits' do
    command 'sudo sysctl -w fs.file-max=65536'
end

template '/etc/security/limits.conf' do
    source 'limits.conf.erb'
    owner 'root'
    group 'root'
    mode 00644
    action :create
end



#### Install Riak Package / Java ####

packagecloud_repo "basho/riak" do
  type "deb" # or "rpm" or "gem"
end

execute 'download java' do
    command 'aws --region us-east-1 s3 cp s3://sendhub-deploy/java/jre-7u25-linux-x64.gz .'
    cwd "/home/#{node[:sendhub][:systemUser]}"
    creates "/home/#{node[:sendhub][:systemUser]}/jre-7u25-linux-x64.gz"
    action :run
end

execute 'build java dir' do
    command 'sudo mkdir -p /usr/lib/jvm ; sudo mv jre-7u25-linux-x64.gz /usr/lib/jvm/.'
    cwd "/home/#{node[:sendhub][:systemUser]}"
    action :run
end

execute 'install java' do
    command 'sudo tar -xvf jre-7u25-linux-x64.gz ; sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jre1.7.0_25/bin/javaws" 1 ; sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jre1.7.0_25/bin/java" 1'
    cwd '/usr/lib/jvm'
    action :run
end

package 'riak' do
    case node[:platform]
    when 'ubuntu'
        package_name 'riak'
    end
    action :install
end

directory '/data' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

directory '/data/riak' do
    owner 'riak'
    group 'riak'
    mode 00700
    action :create
end



####  Install Extractors ####

directory '/data/riak/beams' do
    owner 'riak'
    group 'riak'
    mode 00700
    action :create
end

cookbook_file '/data/riak/beams/yz_contact_json_extractor.erl' do
    owner 'riak'
    group 'riak'
    mode 00755
    action :create
end

execute 'compile yz_contact_json_extractor' do
    command '`find / -type f -name erlc | head -n 1` -o /data/riak/beams/ /data/riak/beams/yz_contact_json_extractor.erl'
    cwd '/data/riak/beams'
    action :run
end

cookbook_file '/data/riak/beams/yz_group_json_extractor.erl' do
    owner 'riak'
    group 'riak'
    mode 00755
    action :create
end

execute 'compile yz_group_json_extractor.erl' do
    command '`find / -type f -name erlc | head -n 1` -o /data/riak/beams/ /data/riak/beams/yz_group_json_extractor.erl'
    cwd '/data/riak/beams'
    action :run
end



#### Install SSL Certs ####

execute 'download cert' do
    command 'aws --region us-east-1 s3 cp s3://sendhub-keychain/riak_server.crt . ; chmod 644 riak_server.crt ; chown riak:riak riak_server.crt'
    cwd '/data/riak'
    action :run
end

execute 'download key' do
    command 'aws --region us-east-1 s3 cp s3://sendhub-keychain/riak_server.key . ; chmod 600 riak_server.key ; chown riak:riak riak_server.key'
    cwd '/data/riak'
    action :run
end

execute 'download cacert' do
    command 'aws --region us-east-1 s3 cp s3://sendhub-keychain/riak_cacert.pem . ; chmod 644 riak_cacert.pem ; chown riak:riak riak_cacert.pem'
    cwd '/data/riak'
    action :run
end



#### Update Riak Config ####

template '/etc/riak/riak.conf' do
    source 'riak.conf.erb'
    owner 'riak'
    group 'riak'
    mode 00644
    action :create
    notifies :restart, "service[riak]"
end

template '/etc/riak/advanced.config' do
    source 'advanced.config.erb'
    owner 'riak'
    group 'riak'
    mode 00644
    action :create
    notifies :restart, "service[riak]"
end

execute "echo 'checking if Riak is running, starting if not'" do
    not_if "pgrep -f riak"
    notifies :start, "service[riak]"
end
