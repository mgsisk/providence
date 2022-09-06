Vagrant.configure('2') do |config|
  ENV['ARCH'] ||= ''
  ENV['HOST'] ||= '@ sys.@'
  ENV['ZONE'] ||= 'America/Detroit'

  config.vm.box = 'bento/debian-11'
  config.vm.box = 'bento/debian-11.2-arm64' if ENV['ARCH'].include? 'arm'
  config.vm.hostname = File.basename(Dir.pwd) + '.test'
  config.vm.network 'private_network', type: 'dhcp'
  config.vm.provision 'shell', inline: 'echo "options single-request-reopen" >>/etc/resolv.conf' if ENV['ARCH'].include? 'arm'
  config.vm.provision 'shell', path: 'dist/provisioner.sh', env: {
    'BUNDLER_CNF' => '/vagrant/docs/Gemfile',
    'ZONE' => ENV['ZONE'],
  }

  config.trigger.after :reload, :resume, :up do |trig|
    trig.info = 'Updating sytstem hosts...'
    trig.ruby do |_env, vm|
      hostname = `vagrant ssh #{vm.name} -c 'hostname -f' -- -q`.chomp
      ip_address = `vagrant ssh #{vm.name} -c 'hostname -I | cut -d " " -f 2' -- -q`.chomp

      system("echo '#{ip_address} #{ENV['HOST'].gsub('@', hostname)} # vagrant-#{vm.id}' | sudo tee -a /etc/hosts >/dev/null") unless Vagrant::Util::Platform.windows?

      if Vagrant::Util::Platform.windows?
        require 'win32ole'
        hFile = File.expand_path('system32/drivers/etc/hosts', ENV['windir'])
        shell = WIN32OLE.new('Shell.Application')
        shell.ShellExecute("echo #{ip_address} #{ENV['HOST'].gsub('@', hostname)} # vagrant-#{vm.id}>> #{hFile}", nil, nil, 'runas')
      end
    end
  end

  config.trigger.before :destroy, :reload do |trig|
    delete_hosts(trig)
  end

  config.trigger.after :halt, :suspend do |trig|
    delete_hosts(trig)
  end
end

def delete_hosts(trig)
  trig.info = 'Updating system hosts...'
  trig.ruby do |_env, vm|
    system("sudo sed -i '' '/ # vagrant-#{vm.id}$/d' /etc/hosts") unless Vagrant::Util::Platform.windows?
    if Vagrant::Util::Platform.windows?
      require 'win32ole'
      hFile = File.expand_path('system32/drivers/etc/hosts', ENV['windir'])
      shell = WIN32OLE.new('Shell.Application')
      shell.ShellExecute("findstr /v /c:\" # vagrant-#{vm.id}$\" #{hFile} >> #{hFile}", nil, nil, 'runas')
    end
  end
end
