# frozen_string_literal: true

require 'chromate/element'

module Chromate
  module Elements
    class Option < Element
      attr_reader :value

      # @param [String] value
      def initialize(value, client, node_id: nil, object_id: nil, root_id: nil)
        super("option[value='#{value}']", client, node_id: node_id, object_id: object_id, root_id: root_id)

        @value = value
      end

      def bounding_box
        script = <<~JAVASCRIPT
          function() {
            const select = this.closest('select');
            const rect = select.getBoundingClientRect();
            return {
              x: rect.x,
              y: rect.y,
              width: rect.width,
              height: rect.height
            };
          }
        JAVASCRIPT

        result = evaluate_script(script)
        # TODO: fix this
        # The offset is due to the fact that the option return the wrong coordinates
        # can be fixed by mesuring an option and use the offset multiply by the index of the option
        {
          'content' => [result['x'] + 100, result['y'] + 100],
          'width' => result['width'],
          'height' => result['height']
        }
      end
    end
  end
end
