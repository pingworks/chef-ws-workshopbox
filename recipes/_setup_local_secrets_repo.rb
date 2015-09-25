#
# Cookbook Name:: ws-workshopbox
#
# Copyright (C) 2015 Alexander Birk
#
# Licensed under the Apache License, Version 2.0
#

directory "/root/secret/user/#{node['ws-workshopbox']['user']['username']}" do
  owner 'root'
  group 'root'
  mode 00700
  recursive true
end

bash 'get user password' do
  code <<-EOC
     scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{node['ws-workshopbox']['secret']['user_key']} #{node['ws-workshopbox']['user']['secret']['password']} /root/secret/user/#{node['ws-workshopbox']['user']['username']}/password
     chmod 0600 /root/secret/user/#{node['ws-workshopbox']['user']['username']}/password
  EOC
end

bash 'get user private key' do
  code <<-EOC
     scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{node['ws-workshopbox']['secret']['user_key']} #{node['ws-workshopbox']['user']['secret']['id_rsa']} /root/secret/user/#{node['ws-workshopbox']['user']['username']}/id_rsa
     chmod 0600 /root/secret/user/#{node['ws-workshopbox']['user']['username']}/id_rsa
  EOC
end

bash 'get user public key' do
  code <<-EOC
     scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{node['ws-workshopbox']['secret']['user_key']} #{node['ws-workshopbox']['user']['secret']['password']} /root/secret/user/#{node['ws-workshopbox']['user']['username']}/id_rsa.pub
     chmod 0644 /root/secret/user/#{node['ws-workshopbox']['user']['username']}/id_rsa.pub
  EOC
end
