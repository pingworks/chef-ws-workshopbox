#
# Cookbook Name:: wsbox_base
# Recipe:: _install_vbox_guest_additions
#
# Copyright (C) 2015 Alexander Birk
#
# Licensed under the Apache License, Version 2.0
#

# a handy tool to detect the running vbox version
cookbook_file 'detect_vboxversion' do
  path '/usr/local/bin/detect_vboxversion'
  mode 0755
end

remote_file node['wsbox_base']['user']['home'] + '/VBoxGuestAdditions_' + node['vboxversion'] + '.iso' do
  source "http://#{node['wsbox_base']['mirror']['vbox']}/virtualbox/#{node['vboxversion']}/VBoxGuestAdditions_#{node['vboxversion']}.iso"
  user node['wsbox_base']['user']['username']
  group node['wsbox_base']['user']['username']
end

[ 'dkms', 'build-essential', "linux-headers-#{node['uname']}"].each do |pkg|
  package pkg
end

bash 'install VBoxGuestAdditions' do
  code <<-EOC
    [ ! -d /tmp/vbox ] && mkdir /tmp/vbox
    mount -o loop #{node['wsbox_base']['user']['home']}/VBoxGuestAdditions_#{node['vboxversion']}.iso /tmp/vbox
    bash /tmp/vbox/VBoxLinuxAdditions.run
    umount /tmp/vbox
    rmdir /tmp/vbox
  EOC
end

["linux-headers-#{node['uname']}", 'build-essential', 'dkms'].each do |pkg|
  package pkg do
    action :remove
  end
end
