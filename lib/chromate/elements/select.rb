# frozen_string_literal: true

require 'chromate/element'
require 'chromate/elements/option'

module Chromate
  module Elements
    class Select < Element
      # @param [String] value
      # @return [self]
      def select_option(value)
        click

        evaluate_script(javascript, arguments: [{ value: value }]) unless Chromate.configuration.native_control

        Option.new(value, client).click

        self
      end

      # @return [String|nil]
      def selected_value
        evaluate_script('function() { return this.value; }')
      end

      # @return [String|nil]
      def selected_text
        evaluate_script('function() {
            const option = this.options[this.selectedIndex];
            return option ? option.textContent.trim() : null;
          }')
      end

      private

      # @return [String]
      def javascript
        <<~JAVASCRIPT
          function() {
            this.focus();
            this.dispatchEvent(new MouseEvent('mousedown'));

            const options = Array.from(this.options);
            const option = options.find(opt =>#{" "}
              opt.value === arguments[0] || opt.textContent.trim() === arguments[0]
            );

            if (!option) {
              throw new Error(`Option '${arguments[0]}' not found in select`);
            }

            this.value = option.value;

            this.dispatchEvent(new Event('change', { bubbles: true }));
            this.dispatchEvent(new Event('input', { bubbles: true }));

            this.blur();
          }
        JAVASCRIPT
      end
    end
  end
end
