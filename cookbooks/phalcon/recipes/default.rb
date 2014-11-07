#
# Cookbook Name:: phalcon
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.
execute "apt-get update" do
    command 'apt-get update'
    ignore_failure false
    action :run
end

required_package = [
    'gcc', 'git', 'libpcre3-dev',
    'make', 'nginx', 'php5-dev',
    'php5-fpm'
]

required_package.each do |package|
    package package do
        action :install
    end
end

service 'php5-fpm' do
    supports    [ :start, :restart, :reload, :status, :stop ]
    action      [ :enable, :reload ]
end

bash 'compile-phalcon' do
    user    'root'
    cwd     '/tmp/cphalcon/build'
    code    './install'
    action  :nothing
end

git '/tmp/cphalcon' do
    repository  'https://github.com/phalcon/cphalcon.git'
    revision    'master'
    action      :sync
    notifies    :run, 'bash[compile-phalcon]'
end

config_direcoties = [
    '/etc/php5/mods-available/phalcon.ini',
    '/etc/php5/fpm/conf.d/phalcon.ini'
]

config_direcoties.each do |path|
    template path  do
        source  'phalcon.ini.erb'
        owner   'root'
        group   'root'
        mode    0644
        notifies :reload, resources(:service => 'php5-fpm'), :immediately
    end
end
