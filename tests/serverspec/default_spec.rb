require "spec_helper"
require "serverspec"

package = ""
service = "dumpcap"
user = "root"
group = "network"
log_dir = "/var/log/dumpcap"
default_user = "root"
default_group = "wheel"
log_dir_owner = user
log_dir_group = group
log_dir_mode = 755
extra_packages = []
interface = ""

case os[:family]
when "openbsd"
  package = "tshark"
  interface = "em0"
  group = "_wireshark"
  log_dir_group = group
when "freebsd"
  package = "wireshark-lite"
  interface = "em0"
when "ubuntu"
  default_group = "root"
  package = "wireshark-common"
  interface = "eth0"
  group = "wireshark"
  log_dir_group = group
end
flags = "-b interval:60 -b files:10 -f ip -g -i #{interface} -q -w #{log_dir}/dumpcap"

describe package(package) do
  it { should be_installed }
end

extra_packages.each do |p|
  describe package p do
    it { should be_installed }
  end
end

describe user(user) do
  it { should exist }
end

describe group(group) do
  it { should exist }
end

describe file(log_dir) do
  it { should be_directory }
  it { should be_mode log_dir_mode }
  it { should be_owned_by log_dir_owner }
  it { should be_grouped_into log_dir_group }
end

case os[:family]
when "openbsd"
  describe file("/etc/rc.conf.local") do
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/^#{Regexp.escape("#{service}_flags=#{flags}")}/) }
  end
when "redhat"
  describe file("/etc/sysconfig/#{service}") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
  end
when "ubuntu"
  describe file("/etc/default/#{service}") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
    its(:content) { should match(/DUMPCAP_FLAGS='#{Regexp.escape(flags)}'/) }
  end

  describe file("/lib/systemd/system/#{service}.service") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
  end
when "freebsd"
  describe file("/etc/rc.conf.d/#{service}") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
    its(:content) { should match(/dumpcap_args='#{flags}'/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

if os[:family] == "openbsd"
  # XXX process does not work on OpenBSD
  describe command("ps -ajxww") do
    its(:stdout) { should match(/root.*dumpcap #{Regexp.escape(flags)}/) }
  end
else
  describe process(service) do
    it { should be_running }
    its(:user) { should eq user }
    its(:group) { should eq os[:family] == "freebsd" ? default_group : group }
    its(:count) { should eq 1 }
    its(:args) { should match(/#{Regexp.escape(flags)}/) }
  end
end
