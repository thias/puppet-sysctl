require 'spec_helper'

describe 'sysctl::base', type: :class do
  let(:facts) do
    {
      os: {
        family:  'RedHat',
        release: {
          major: '8',
        },
      },
    }
  end

  it { is_expected.to create_class('sysctl::base') }
  it { is_expected.to contain_file('/etc/sysctl.d') }
end
