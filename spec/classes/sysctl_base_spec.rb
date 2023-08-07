require 'spec_helper'

describe 'sysctl::base', :type => :class do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystemmajrelease: '8',
    }
  end

  let(:facts) do
    {
      :osfamily => 'RedHat',
      :operatingsystemmajrelease => '8',
    }
  end

  it { should create_class('sysctl::base') }
  it { should contain_file('/etc/sysctl.d') }

end

