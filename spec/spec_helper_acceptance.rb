# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker

module LocalHelpers
  def gpg(gpg_cmd, user: 'root', **options, &block)
    options[:acceptable_exit_codes] ||= [0]
    gpg = "gpg #{gpg_cmd}"
    shell("su #{user} -c \"#{gpg}\"", options, &block)
  end
end

RSpec.configure do |c|
  c.include ::LocalHelpers
end
