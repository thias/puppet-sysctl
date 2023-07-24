# frozen_string_literal: true

require 'spec_helper'

describe 'sysctl' do
  let(:title) { 'net.ipv4.ip_forward' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'present' do
        let(:params) { { value: '1' } }

        it { is_expected.to compile }
        it do
          is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with(
            content: "net.ipv4.ip_forward = 1\n",
            ensure: nil,
          )
        end

        it { is_expected.to contain_exec('sysctl-net.ipv4.ip_forward') }
        it { is_expected.to contain_exec('update-sysctl.conf-net.ipv4.ip_forward') }
      end

      context 'absent' do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to compile }
        it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with_ensure('absent') }
      end
    end
  end
end
