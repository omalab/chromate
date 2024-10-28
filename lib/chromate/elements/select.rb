# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Select < Element
      # @param [String] selector
      def select_option(value)
        click
        opt = find_elements('option').find do |option|
          option.attributes['value'] == value
        end
        opt.set_attribute('selected', 'true')
        click
      end
    end
  end
end
