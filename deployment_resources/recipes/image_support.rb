package 'libjpeg-dev' do
    case node[:platform]
    when 'ubuntu'
        package_name 'libjpeg-dev'
    end
    action :install
end

package 'libgif-dev' do
    case node[:platform]
    when 'ubuntu'
        package_name 'libgif-dev'
    end
    action :install
end


package 'libpng-dev' do
    case node[:platform]
    when 'ubuntu'
        package_name 'libpng-dev'
    end
    action :install
end


package 'libtiff-dev' do
    case node[:platform]
    when 'ubuntu'
        package_name 'libtiff-dev'
    end
    action :install
end

