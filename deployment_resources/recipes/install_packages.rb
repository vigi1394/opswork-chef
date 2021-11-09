apt_repository "postgresql" do
    uri "http://apt.postgresql.org/pub/repos/apt/"
    distribution node['lsb']['codename'] + '-pgdg'
    components ["main"]
    key 'https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc'
end

package 'python-dev' do
    case node[:platform]
        when 'ubuntu'
            package_name 'python-dev'
    end
    action :upgrade
end

package 'rsyslog-gnutls' do
    case node[:platform]
        when 'ubuntu'
            package_name 'rsyslog-gnutls'
    end
    action :upgrade
end

package 'memcached-lib' do
    case node[:platform]
        when 'ubuntu'
            package_name 'libmemcached-dev'
    end
    action :upgrade
end

package 'postgresql-lib' do
    case node[:platform]
        when 'ubuntu'
            package_name 'libpq-dev'
    end
    action :upgrade
end

package 'postgresql-keyring' do
    case node[:platform]
      when 'ubuntu'
          package_name 'pgdg-keyring'
    end
end

package 'python-virtualenv' do
    case node[:platform]
        when 'ubuntu'
            package_name 'python-virtualenv'
    end
    action :upgrade
end

package 'daemontools' do
    case node[:platform]
        when 'ubuntu'
            package_name 'daemontools'
    end
    action :upgrade
end

package 'python-pip' do
    case node[:platform]
        when 'ubuntu'
            package_name 'python-pip'
    end
    action :upgrade
end

package 'language-pack-en' do
    case node[:platform]
        when 'ubuntu'
            package_name 'language-pack-en'
    end
    action :upgrade
end

execute 'configure locales' do
    command "sudo dpkg-reconfigure locales"
end

directory "/home/ubuntu/.aws" do
    owner "ubuntu"
    group "ubuntu"
    mode 0700
    action :create
end

template "/home/ubuntu/.aws/config" do
    source "aws_config.erb"
    owner "ubuntu"
    group "ubuntu"
    mode 0600
end
