#
# Cookbook Name:: vncserver
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "apt-get update" do
  ignore_failure true
  action :nothing
end.run_action(:run) if node['platform_family'] == "ubuntu"


case node['platform']
when "ubuntu"
	package "vnc4server" do
		action :install
	end
end


case node['platform']
when "ubuntu"
	directory "/home/ubuntu/.vnc" do
		owner "ubuntu"
		group "ubuntu"
		mode 00755
		action :create
	end
end


case node['platform']
when "ubuntu"
	cookbook_file "/home/ubuntu/.vnc/xstartup" do
		owner 'ubuntu'
		group 'ubuntu'
		source "xstartup"
		mode "0755"
	end
end


script "vncpasswd" do
        interpreter "bash"
	user 'ubuntu'
	cwd '/home/ubuntu'
        code <<-EOH
		echo #{node['vncserver']['_VNCSERVER_PASSWORD']} > /home/ubuntu/pass.txt 
		echo #{node['vncserver']['_VNCSERVER_PASSWORD']} >> /home/ubuntu/pass.txt
		echo >> /home/ubuntu/pass.txt
		/usr/bin/vncpasswd < /home/ubuntu/pass.txt
		rm -rf /home/ubuntu/pass.txt
        EOH
	creates "/home/ubuntu/.vnc/passwd"
end


script "vncserver" do
        interpreter "bash"
	user 'ubuntu'
	cwd '/home/ubuntu'
        code <<-EOH
		/usr/bin/vncserver :1 &
		nohup /home/ubuntu/.vnc/xstartup &
        EOH
	environment 'DISPLAY' => ':1'
end
