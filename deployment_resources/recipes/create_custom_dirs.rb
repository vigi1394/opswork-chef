for layer in node[:opsworks][:instance][:layers] do
  for custom_path in node[:sendhub][:layers][layer][:customDirs] do
    directory custom_path do
      owner "ubuntu"
      group "ubuntu"
      action :create
    end
  end
end