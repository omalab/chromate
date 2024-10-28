# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Select < Element
      # @param [String] selector
      def select_option(selector)
        click
        value = find_element(selector).attributes['value']
        set_attribute('value', value)
        click
      end
    end
  end
end
