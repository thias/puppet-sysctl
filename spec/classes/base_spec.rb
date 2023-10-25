require 'spec_helper'

describe 'sysctl::base', type: :class do
  on_supported_os.sort.each do |os, facts|
    # define os specific defaults
    symlink99 = if (facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'].to_i >= 7) ||
                   (facts[:os]['family'] == 'Debian' && facts[:os]['release']['major'].to_i >= 8)
                  true
                else
                  false
                end

    describe "on #{os} with default values for parameters" do
      let(:facts) { facts }

      it { is_expected.to create_class('sysctl::base') }
      it { is_expected.to contain_class('sysctl::params') }

      it do
        is_expected.to contain_file('/etc/sysctl.d').only_with(
          'ensure'  => 'directory',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755',
          'purge'   => false,
          'recurse' => false,
        )
      end

      if symlink99 == true
        it do
          is_expected.to contain_file('/etc/sysctl.d/99-sysctl.conf').only_with(
            'ensure' => 'link',
            'owner'  => 'root',
            'group'  => 'root',
            'target' => '../sysctl.conf',
          )
        end
      else
        it { is_expected.not_to contain_file('/etc/sysctl.d/99-sysctl.conf') }
      end
    end
  end

  describe 'parameters on supported OS' do
    # tests should be OS independent, so we only test one OS
    test_on = {
      supported_os: [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['8'],
        },
      ],
    }
    on_supported_os(test_on).sort.each do |_os, os_facts|
      let(:facts) { os_facts }

      context 'with with purge set to valid true' do
        let(:params) { { purge: true } }

        it { is_expected.to contain_file('/etc/sysctl.d').with_purge(true) }
        it { is_expected.to contain_file('/etc/sysctl.d').with_recurse(true) }
      end

      context 'with with values set to valid value' do
        let(:params) do
          {
            values: {
              'net.ipv4.ip_forward' => {
                'value' => '1',
              },
              'net.core.somaxconn' => {
                'value' => '65536',
              },
              'vm.swappiness' => {
                'ensure' => 'absent',
              },
            }
          }
        end

        it { is_expected.to contain_sysctl('net.ipv4.ip_forward').with_value('1') }
        it { is_expected.to contain_sysctl('net.core.somaxconn').with_value('65536') }
        it { is_expected.to contain_sysctl('vm.swappiness').with_ensure('absent') }

        # [only here to reach 100% resource coverage]
        it { is_expected.to contain_exec('enforce-sysctl-value-net.ipv4.ip_forward') }
        it { is_expected.to contain_exec('sysctl-net.ipv4.ip_forward') }
        it { is_expected.to contain_exec('update-sysctl.conf-net.ipv4.ip_forward') }
        it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf') }
        it { is_expected.to contain_exec('enforce-sysctl-value-net.core.somaxconn') }
        it { is_expected.to contain_exec('sysctl-net.core.somaxconn') }
        it { is_expected.to contain_exec('update-sysctl.conf-net.core.somaxconn') }
        it { is_expected.to contain_file('/etc/sysctl.d/net.core.somaxconn.conf') }
        it { is_expected.to contain_file('/etc/sysctl.d/vm.swappiness.conf') }
        # [/only here to reach 100% resource coverage]
      end

      context 'with with symlink99 set to valid true' do
        let(:params) { { symlink99: true } }

        it { is_expected.to contain_file('/etc/sysctl.d/99-sysctl.conf') }
      end

      context 'with with symlink99 set to valid true when sysctl_dir_path is set to /test/ing (directory outside /etc)' do
        let(:params) { { symlink99: true, sysctl_dir_path: '/test/ing' } }

        it { is_expected.not_to contain_file('/test/ing/99-sysctl.conf') }
        it { is_expected.to contain_file('/test/ing') }
        it { is_expected.to have_file_resource_count(1) }
      end

      context 'with with symlink99 set to valid true when sysctl_dir_path is set to /etc/testing (directory inside /etc)' do
        let(:params) { { symlink99: true, sysctl_dir_path: '/etc/testing' } }

        it { is_expected.to contain_file('/etc/testing/99-sysctl.conf') }
      end

      context 'with with symlink99 set to valid false' do
        let(:params) { { symlink99: false } }

        it { is_expected.not_to contain_file('/etc/sysctl.d/99-sysctl.conf') }
        it { is_expected.to have_file_resource_count(1) } # only '/etc/sysctl.d'
      end

      context 'with with sysctl_dir set to valid false' do
        let(:params) { { sysctl_dir: false } }

        it { is_expected.not_to contain_file('/etc/sysctl.d/99-sysctl.conf') }
        it { is_expected.to have_file_resource_count(0) }
      end

      context 'with with sysctl_dir_path set to valid value' do
        let(:params) { { sysctl_dir_path: '/etc/testing' } }

        it { is_expected.to contain_file('/etc/testing') }
        it { is_expected.to contain_file('/etc/testing/99-sysctl.conf') }
      end

      context 'with with sysctl_dir_owner set to valid value' do
        let(:params) { { sysctl_dir_owner: 'testing' } }

        it { is_expected.to contain_file('/etc/sysctl.d').with_owner('testing') }
        it { is_expected.to contain_file('/etc/sysctl.d/99-sysctl.conf').with_owner('testing') }
      end

      context 'with with sysctl_dir_group set to valid value' do
        let(:params) { { sysctl_dir_group: 'testing' } }

        it { is_expected.to contain_file('/etc/sysctl.d').with_group('testing') }
        it { is_expected.to contain_file('/etc/sysctl.d/99-sysctl.conf').with_group('testing') }
      end

      context 'with with sysctl_dir_mode set to valid value' do
        let(:params) { { sysctl_dir_mode: '0242' } }

        it { is_expected.to contain_file('/etc/sysctl.d').with_mode('0242') }
      end
    end
  end
end
