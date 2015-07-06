directory "/etc/profile.d" do
  action :create
  mode "0755"
  owner "root"
  group "admin"
end

execute "update /etc/profile to include files from the /etc/profile.d directory" do
  action :run
  file = "/etc/profile"
  command "echo \"for s in \\$( ls /etc/profile.d/*.sh ); do . \\$s; done #profile.d written by chef\" >> #{file}"
  not_if "grep 'profile.d written by chef' #{file}"
end

# am I running in kitchenplan?
return unless node['current_user']

directory ::File.join(::Dir.home(node['current_user']), ".profile.d") do
  action :create
  owner node['current_user']
  group node['current_user']
  mode "0700"
end

execute "update the local bashrc for user #{node['current_user']} to include their ~/.profile.d directory" do
  action :run
  file = ".bash_profile"
  command "echo \"for s in \\$( ls ~/.profile.d/*.sh ); do . \\$s; done #profile.d written by chef\" >> ~/#{file}"
  user node['current_user']
  not_if "grep 'profile.d written by chef' ~/#{file}"
end

file "raise the ulimit for duplicity" do
  action :create
  path ::File.join(::Dir.home(node['current_user']), ".profile.d", "ulimit.sh")
  content "ulimit -n 1024"
  owner node['current_user']
  group node['current_user']
  mode "0700"
end
