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
when "amazon"
	cookbook_file "/etc/yum.repos.d/cent.repo" do
		owner 'root'
		group 'root'
		source "cent.repo"
		mode "0644"
	end
end

# vncserver のインストール
case node['platform']
when "ubuntu"
	package "vnc4server" do
		action :install
	end
when "centos","amazon"
	package "tigervnc-server" do
		action :install
	end
end


# vncserver の設定ファイルの設置
case node['platform']
when "centos","amazon"
	cookbook_file "/etc/sysconfig/vncservers" do
		owner 'root'
		group 'root'
		source "vncservers"
		mode "0755"
	end
end


# .vnc directory の作成
case node['platform']
when "ubuntu"
	directory "/home/ubuntu/.vnc" do
		owner "ubuntu"
		group "ubuntu"
		mode 00755
		action :create
	end
when "centos","amazon"
	directory "/root/.vnc" do
		owner "root"
		group "root"
		mode 00755
		action :create
	end
end


# xstartup の設置
case node['platform']
when "ubuntu"
	cookbook_file "/home/ubuntu/.vnc/xstartup" do
		owner 'ubuntu'
		group 'ubuntu'
		source "xstartup_ubuntu"
		mode "0755"
	end
when "centos","amazon"
	cookbook_file "/root/.vnc/xstartup" do
		owner 'root'
		group 'root'
		source "xstartup_centos"
		mode "0755"
	end
end


# VNC ログイン用パスワードの準備
case node['platform']
when "ubuntu"
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
when "centos","amazon"
script "vncpasswd" do
	interpreter "bash"
	user 'root'
	cwd '/root'
       	code <<-EOH
		echo #{node['vncserver']['_VNCSERVER_PASSWORD']} > /root/vncpasswd 
		cat /root/vncpasswd | vncpasswd -f > /root/.vnc/passwd
		rm -rf /root/vncpasswd
		chmod 600 /root/.vnc/passwd
       	EOH
	creates "/root/.vnc/passwd"
end
end


# vncserver の起動
case node['platform']
when "ubuntu"
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
when "centos","amazon"
service "vncserver" do
	action :start
end
end
