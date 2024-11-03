# frozen_string_literal: true

require_relative 'chromate/version'
require_relative 'chromate/browser'
require_relative 'chromate/configuration'

module Chromate
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
