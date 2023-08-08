require 'spec_helper'

describe 'sysctl', type: :define do
  let(:title) { 'net.ipv4.ip_forward' }

  header = <<-END.gsub(%r{^\s+\|}, '')
    |# This file is being maintained by Puppet.
    |# DO NOT EDIT
    |
  END

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

      it { is_expected.to contain_class('sysctl::base') }
      # [only here to reach 100% resource coverage]
      it { is_expected.to contain_class('sysctl::params') }
      it { is_expected.to contain_file('/etc/sysctl.d/99-sysctl.conf') } if symlink99 == true
      # [/only here to reach 100% resource coverage]

      it do
        is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').only_with(
          ensure:   'present',
          owner:    'root',
          group:    'root',
          mode:     '0644',
          content:  header + "net.ipv4.ip_forward = \n",
          source:   nil,
          notify:   ['Exec[sysctl-net.ipv4.ip_forward]', 'Exec[update-sysctl.conf-net.ipv4.ip_forward]'],
        )
      end

      it do
        is_expected.to contain_exec('sysctl-net.ipv4.ip_forward').only_with(
          command:     'sysctl -p /etc/sysctl.d/net.ipv4.ip_forward.conf',
          path:        ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
          refreshonly: true,
          require:     'File[/etc/sysctl.d/net.ipv4.ip_forward.conf]',
        )
      end

      it do
        is_expected.to contain_exec('update-sysctl.conf-net.ipv4.ip_forward').only_with(
          command:     "sed -i -e 's#^net.ipv4.ip_forward *=.*#net.ipv4.ip_forward = #' /etc/sysctl.conf",
          path:        ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
          refreshonly: true,
          onlyif:      "grep -E '^net.ipv4.ip_forward *=' /etc/sysctl.conf",
        )
      end

      it do
        is_expected.to contain_exec('enforce-sysctl-value-net.ipv4.ip_forward').only_with(
          unless:  'test "$(sysctl -n net.ipv4.ip_forward)" = ""',
          command: 'sysctl -w net.ipv4.ip_forward=""',
          path:    ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        )
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

      context 'with ensure set to valid absent' do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').only_with_ensure('absent') }
      end

      context 'with value set to valid 1' do
        let(:params) { { value: '1' } }

        it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with_content(header + "net.ipv4.ip_forward = 1\n") }

        it do
          is_expected.to contain_exec('update-sysctl.conf-net.ipv4.ip_forward').with_command(
            "sed -i -e 's#^net.ipv4.ip_forward *=.*#net.ipv4.ip_forward = 1#' /etc/sysctl.conf",
          )
        end

        it do
          is_expected.to contain_exec('enforce-sysctl-value-net.ipv4.ip_forward').only_with(
            unless:  'test "$(sysctl -n net.ipv4.ip_forward)" = 1',
            command: 'sysctl -w net.ipv4.ip_forward=1',
            path:    ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
          )
        end
      end

      context 'with prefix set to valid .testing' do
        let(:params) { { prefix: 'testing' } }

        it { is_expected.to contain_file('/etc/sysctl.d/testing-net.ipv4.ip_forward.conf') }
        it do
          is_expected.to contain_exec('sysctl-net.ipv4.ip_forward').with(
            command: 'sysctl -p /etc/sysctl.d/testing-net.ipv4.ip_forward.conf',
            require: 'File[/etc/sysctl.d/testing-net.ipv4.ip_forward.conf]',
          )
        end
      end

      context 'with prefix set to valid .testing when ensure is set to absent' do
        let(:params) { { prefix: 'testing', ensure: 'absent' } }

        it { is_expected.to contain_file('/etc/sysctl.d/testing-net.ipv4.ip_forward.conf') }
      end

      context 'with suffix set to valid .testing' do
        let(:params) { { suffix: '.testing' } }

        it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.testing') }
        it do
          is_expected.to contain_exec('sysctl-net.ipv4.ip_forward').with(
            command: 'sysctl -p /etc/sysctl.d/net.ipv4.ip_forward.testing',
            require: 'File[/etc/sysctl.d/net.ipv4.ip_forward.testing]',
          )
        end
      end

      context 'with suffix set to valid .testing when ensure is set to absent' do
        let(:params) { { suffix: '.testing', ensure: 'absent' } }

        it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.testing') }
      end

      context 'with comment set to valid string testing' do
        let(:params) { { comment: 'testing' } }

        it do
          is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with(
            content: header + "# testing\nnet.ipv4.ip_forward = \n",
          )
        end
      end

      context 'with comment set to valid array [test, ing]' do
        let(:params) { { comment: ['test', 'ing'] } }

        it do
          is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with(
            content: header + "# test\n# ing\nnet.ipv4.ip_forward = \n",
          )
        end
      end

      context 'with content set to valid testing' do
        let(:params) { { content: 'testing' } }

        it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with_content('testing') }
      end

      context 'with source set to valid testing' do
        let(:params) { { source: 'testing' } }

        it { is_expected.to contain_file('/etc/sysctl.d/net.ipv4.ip_forward.conf').with_source('testing') }
      end

      context 'with enforce set to valid false' do
        let(:params) { { enforce: false } }

        it { is_expected.not_to contain_exec('enforce-sysctl-value-net.ipv4.ip_forward') }
      end
    end
  end
end
