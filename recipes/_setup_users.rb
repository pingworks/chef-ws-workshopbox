#
# Cookbook Name:: ws-workshopbox
# Recipe:: _setup_user
#
# Copyright (C) 2015 Alexander Birk
#
# Licensed under the Apache License, Version 2.0
#


Dir.foreach(node['ws-workshopbox']['secret-service']['client']['repo'] + '/user') do |username|
  next if username == '.' or username == '..'
  bash 'create user' + username do
    code <<-EOC
      useradd #{username} --create-home --shell /bin/bash --groups adm,cdrom,sudo,dip,plugdev,lpadmin,sambashare
      echo #{username}:$(< #{node['ws-workshopbox']['secret-service']['client']['repo']}/user/#{username}/password) | chpasswd
    EOC
    not_if do File.exist?("/home/#{username}") end
  end

  bash 'create users ' + username + ' .ssh settings' do
    code <<-EOC
      mkdir /home/#{username}/.ssh
      cp #{node['ws-workshopbox']['secret-service']['client']['repo']}/user/#{username}/.ssh/authorized_keys /home/#{username}/.ssh/authorized_keys
      cp #{node['ws-workshopbox']['secret-service']['client']['repo']}/user/#{username}/.ssh/id_rsa.pub /home/#{username}/.ssh/id_rsa.pub
      cp #{node['ws-workshopbox']['secret-service']['client']['repo']}/user/#{username}/.ssh/id_rsa /home/#{username}/.ssh/id_rsa
      chown -R #{username}.#{username} /home/#{username}/.ssh
      chmod -R go-rwsx /home/#{username}/.ssh
    EOC
    not_if do File.exist?("/home/#{username}/.ssh/id_rsa") end
  end

  %w(.vimrc .bash_logout .bashrc .dmrc .profile .xinputrc).each do |f|
    cookbook_file "/home/#{username}/#{f}" do
      owner username
      group username
      mode 00644
    end
  end

  %w(.config .gconf .local).each do |d|
    directory "/home/#{username}/#{d}" do
      owner username
      group username
      mode 00755
    end
  end

  %w(dconf gnome-session gtk-3.0 update-notifier upstart).each do |d|
    directory "/home/#{username}/.config/#{d}" do
      owner username
      group username
      mode 00755
    end
  end

  %w(user-dirs.dirs user-dirs.locale).each do |f|
    cookbook_file "/home/#{username}/.config/#{f}" do
      owner username
      group username
      mode 00644
    end
  end

  cookbook_file "/home/#{username}/.config/dconf/user" do
    owner username
    group username
    mode 00644
  end

  template "/home/#{username}/.config/gtk-3.0/bookmarks" do
    owner username
    group username
    mode 00644
    variables({
      :username => username
    })
  end

  bash 'setup git' do
    user username
    group username
    environment ({'HOME' => "/home/#{username}", 'USER' => username })
    code <<-EOC
      git config --global user.email "$(<#{node['ws-workshopbox']['secret-service']['client']['repo']}/user/#{username}/email)"
      git config --global user.name "$(<#{node['ws-workshopbox']['secret-service']['client']['repo']}/user/#{username}/fullname)"
    EOC
  end

  cookbook_file "/home/#{username}/.ssh/config" do
    owner username
    group username
    mode 0600
  end

  directory "/home/#{username}/workspace/cookbooks/" do
    owner username
    group username
    mode 00755
    recursive true
  end

  directory '/home/#{username}/.mofa' do
    owner username
    group username
    mode 00755
    recursive true
    action :create
  end

  template '/home/#{username}/.mofa/config.yml' do
    source 'config.yml.user'
    owner username
    group username
    mode 00644
  end
end
