# frozen_string_literal: true

require 'spec_helper'

describe 'sysctl::base' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to create_class('sysctl::base') }
      it { is_expected.to contain_file('/etc/sysctl.d') }
    end
  end
end
