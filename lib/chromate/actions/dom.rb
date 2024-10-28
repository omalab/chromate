# frozen_string_literal: true

module Chromate
  module Actions
    module Dom
      def find_element(selector)
        Chromate::Element.new(selector, @client)
      end

      def click_element(selector)
        find_element(selector).click
      end

      def hover_element(selector)
        find_element(selector).hover
      end

      def type_text(selector, text)
        find_element(selector).type(text)
      end

      def get_text(selector)
        find_element(selector).text
      end

      def get_property(selector, property)
        find_element(selector).attributes[property]
      end

      def select_option(selector, option)
        Chromate::Elements::Select.new(selector, @client).select_option(option)
      end

      def evaluate_script(script)
        @client.send_message('Runtime.evaluate', expression: script)
      end
    end
  end
end
