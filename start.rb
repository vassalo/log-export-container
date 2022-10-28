if ENV["SDM_ADMIN_TOKEN"]
  puts('Starting SDM')
  result = system("sdm --admin-token #{ENV['SDM_ADMIN_TOKEN']} login")
  unless result
    puts "You need to install SDM CLI."
    return
  end
  listen_thread = Thread.new { system('sdm listen', :out => File::NULL, :err => File::NULL) }
  until system('sdm status', :out => File::NULL) do
    sleep(1)
  end
end

puts("Creating Fluentd conf file")
require "#{ENV['FLUENTD_DIR']}/../create-conf.rb"

fluentd_pkg_name = "fluentd"
fluentd_pkg_version = "> 0.a"

puts("Starting Fluentd")

if Gem.respond_to?(:activate_bin_path)
  fluentd_path = Gem.activate_bin_path(fluentd_pkg_name, fluentd_pkg_name, fluentd_pkg_version)
else
  fluentd_path = Gem.bin_path(fluentd_pkg_name, fluentd_pkg_name, fluentd_pkg_version)
end

system("#{fluentd_path} -c #{ENV['FLUENTD_DIR']}/etc/fluent.conf -p #{ENV['FLUENTD_DIR']}/plugins")
