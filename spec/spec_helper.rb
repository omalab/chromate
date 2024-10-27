# frozen_string_literal: true

require 'chromate'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.include Support::Server

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
