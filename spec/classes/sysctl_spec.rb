require 'spec_helper'

describe 'sysctl', :type => :class do

  it { should create_class('sysctl') }
  it { should contain_file('/etc/sysctl.d') }

end

