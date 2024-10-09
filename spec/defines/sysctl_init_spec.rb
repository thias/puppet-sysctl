require 'spec_helper'

describe 'sysctl', type: :define do
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

  let(:title) { 'net.ipv4.ip_forward' }

  let(:facts) do
    {
      :osfamily => 'RedHat',
      :operatingsystemmajrelease => '8',
    }
  end

  context 'present' do
    let(:params) { { value: '1' } }

    it {
      is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with(
        content:  "net.ipv4.ip_forward = 1\n",
        ensure:   nil,
      )
    }

    it { is_expected.to contain_exec('sysctl-net.ipv4.ip_forward') }
    it { is_expected.to contain_exec('update-sysctl.conf-net.ipv4.ip_forward') }
  end

  context 'absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with_ensure('absent') }
  end
end
