#
# Cookbook Name:: haproxy
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#package 'haproxy' do
#  action :install
#end

# Setup the HA Proxy repository
apt_repository 'haproxy-1.5' do
  uri          'ppa:vbernat/haproxy-1.5'
  distribution 'precise'
end

# Install specific version of HA Proxy
package 'haproxy' do
  action :install
  version node['haproxy']['version']
end

if platform?('debian','ubuntu')
  template '/etc/default/haproxy' do
    source 'haproxy-default.erb'
    owner 'root'
    group 'root'
    mode 0644
  end
end

include_recipe 'haproxy::service'

service 'haproxy' do
  action [:enable, :start]
end

# Create certs.d directory
directory '/etc/haproxy/certs.d' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

# Put *.sendhub.com cert into certs.d directory
execute 'download cacert' do
  command 'aws --region us-east-1 s3 cp s3://sendhub-keychain/star_sendhub_com-full.pem .'
  cwd '/etc/haproxy/certs.d'
  action :run
end

# Delete the haproxy rsyslog config file
file '/etc/rsyslog.d/49-haproxy.conf' do
  action :delete
end

template '/etc/haproxy/haproxy.cfg' do
  source 'haproxy.cfg.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables({
    :layers => node[:sendhub][:layers]
  })
  notifies :restart, "service[haproxy]"
end
