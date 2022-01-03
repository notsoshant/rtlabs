require 'json'

vagrant_config = JSON.parse(File.read('config.json'))

Vagrant.configure("2") do |config|
  config.vm.usable_port_range = 2200..2299
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "dc", primary: true do |dc|
    dc.vm.guest = :windows
    dc.vm.communicator = "winrm"
    dc.vm.boot_timeout = 600
    dc.vm.graceful_halt_timeout = 600
    dc.winrm.retry_limit = 30
    dc.winrm.retry_delay = 10
    dc.vm.box = vagrant_config['boxes']['dc']['box']

    dc.vm.provider vagrant_config['provider'] do |v|
      v.gui = true
      v.cpus = vagrant_config['boxes']['dc']['cpus']
      v.memory = vagrant_config['boxes']['dc']['memory']
      v.base_address = vagrant_config['boxes']['dc']['ip']
      v.base_mac = "00:50:56:39:89:A4"
    end
    
  end

  config.vm.define "srv01" do |srv01|
    srv01.vm.guest = :windows
    srv01.vm.communicator = "winrm"
    srv01.vm.boot_timeout = 600
    srv01.vm.graceful_halt_timeout = 600
    srv01.winrm.retry_limit = 30
    srv01.winrm.retry_delay = 10
    srv01.vm.box = vagrant_config['boxes']['srv01']['box']

    srv01.vm.provider vagrant_config['provider'] do |v|
      v.gui = true
      v.cpus = vagrant_config['boxes']['srv01']['cpus']
      v.memory = vagrant_config['boxes']['srv01']['memory']
      v.base_address = vagrant_config['boxes']['srv01']['ip']
      v.base_mac = "00:50:56:39:89:A1"
    end
    
  end

  config.vm.define "srv02" do |srv02|
    srv02.vm.guest = :windows
    srv02.vm.communicator = "winrm"
    srv02.vm.boot_timeout = 600
    srv02.vm.graceful_halt_timeout = 600
    srv02.winrm.retry_limit = 30
    srv02.winrm.retry_delay = 10
    srv02.vm.box = vagrant_config['boxes']['srv02']['box']

    srv02.vm.provider vagrant_config['provider'] do |v|
      v.gui = true
      v.cpus = vagrant_config['boxes']['srv02']['cpus']
      v.memory = vagrant_config['boxes']['srv02']['memory']
      v.base_address = vagrant_config['boxes']['srv02']['ip']
      v.base_mac = "00:50:56:39:89:A2"
    end
    
  end

  config.vm.define "wkt01" do |wkt01|
    wkt01.vm.guest = :windows
    wkt01.vm.communicator = "winrm"
    wkt01.vm.boot_timeout = 600
    wkt01.vm.graceful_halt_timeout = 600
    wkt01.winrm.retry_limit = 30
    wkt01.winrm.retry_delay = 10
    wkt01.vm.box = vagrant_config['boxes']['wkt01']['box']

    wkt01.vm.provider vagrant_config['provider'] do |v|
      v.gui = true
      v.cpus = vagrant_config['boxes']['wkt01']['cpus']
      v.memory = vagrant_config['boxes']['wkt01']['memory']
      v.base_address = vagrant_config['boxes']['wkt01']['ip']
      v.base_mac = "00:50:56:39:89:A3"
    end
    
  end

  config.vm.define "kali" do |kali|
    kali.vm.box = vagrant_config['boxes']['kali']['box']

    kali.vm.provider vagrant_config['provider'] do |v|
      v.gui = true
      v.cpus = vagrant_config['boxes']['kali']['cpus']
      v.memory = vagrant_config['boxes']['kali']['memory']
      v.base_address = vagrant_config['boxes']['kali']['ip']
      v.base_mac = "00:50:56:39:89:A5"
    end

  end

end