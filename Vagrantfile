Vagrant.configure('2') do |conf|
  ENV['ZONE'] ||= 'America/Detroit'

  is_arm64 = (`uname -m` == 'arm64' || `uname -m` == 'aarch64' || `command -v sysctl >/dev/null && arch -64 sh -c "sysctl -in sysctl.proc_translated"`.strip == '0')
  zsh = File.file?(File.expand_path '~/.zshrc')

  conf.vm.box = 'debian/contrib-buster64'
  conf.vm.box = 'bento/debian-11.2-arm64' if is_arm64
  conf.vm.hostname = File.basename(Dir.pwd) + '.test'
  conf.vm.network 'private_network', type: 'dhcp'
  [
    '~/.gitconfig',
    '~/.gitignore',
    '~/.npmrc',
    '~/.vimrc',
    '~/.zprofile',
    '~/.zshenv',
    '~/.zshrc',
  ].each {|pFile| conf.vm.provision 'file', source: pFile, destination: pFile if File.file?(File.expand_path pFile)}
  conf.vm.provision 'shell', inline: 'echo "options single-request-reopen" >>/etc/resolv.conf' if is_arm64
  conf.vm.provision 'shell', path: 'dist/provisioner.sh', env: {
    'BUNDLER_CNF' => '/vagrant/docs/Gemfile',
    'LOGIN_SHELL_CNF' => ('.zprofile' if zsh),
    'LOGIN_SHELL' => ('/bin/zsh' if zsh),
    'ZONE' => ENV['ZONE'],
  }.compact

  conf.trigger.before :destroy, :halt, :reload, :suspend do |t|
    t.info = 'Updating system hosts...'
    t.ruby do |env, vm|
      command = "sudo sed -i '' '/ # vagrant-#{vm.id}$/d' /etc/hosts"
      command = "type %WINDIR%\\system32\\drivers\\etc\\hosts | findstr /e /v /c:vagrant-#{vm.id}>prov-hosts && move /Y prov-hosts %WINDIR%\\system32\\drivers\\etc\\hosts" if Vagrant::Util::Platform.windows?
      system(command)
    end
  end

  conf.trigger.after :reload, :resume, :up do |t|
    t.info = 'Updating sytstem hosts...'
    t.ruby do |env, vm|
      hostname = `vagrant ssh #{vm.name} -c 'hostname -f' -- -q`.chomp
      ip_address = `vagrant ssh #{vm.name} -c 'hostname -I | cut -f2 -d\\ ' -- -q`.chomp
      command = "echo '#{ip_address} #{hostname} sys.#{hostname} # vagrant-#{vm.id}' | sudo tee -a /etc/hosts >/dev/null"
      command = "echo #{ip_address} #{hostname} sys.#{hostname} # vagrant-#{vm.id}>> %WINDIR%\\system32\\drivers\\etc\\hosts" if Vagrant::Util::Platform.windows?
      system(command)
    end
  end
end
