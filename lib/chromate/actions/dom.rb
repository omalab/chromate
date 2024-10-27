# frozen_string_literal: true

module Chromate
  module Actions
    module Dom
      def find_element(selector)
        Chromate::Element.new(selector, @client)
      end

      def click_element(selector)
        element = find_element(selector)
        controller = Chromate::Native::MouseController.new(@client)
        controller.click(element.x, element.y)
      end

      def hover_element(selector)
        element = find_element(selector)
        controller = Chromate::Native::MouseController.new(@client)
        controller.move_to(element.x, element.y)
      end

      def type_text(selector, text)
        object_id = find_element(selector)
        @client.send_message('Runtime.callFunctionOn', functionDeclaration: "function(value) { this.value = value; this.dispatchEvent(new Event('input')); }",
                                                       objectId: object_id, arguments: [{ value: text }])
      end

      def get_text(selector)
        object_id = find_element(selector)
        result = @client.send_message('Runtime.callFunctionOn', functionDeclaration: 'function() { return this.textContent; }', objectId: object_id)
        result['result']['value']
      end

      def get_property(selector, property)
        object_id = find_element(selector)
        result = @client.send_message('Runtime.callFunctionOn', functionDeclaration: "function() { return this['#{property}']; }", objectId: object_id)
        result['result']['value']
      end

      def evaluate_script(script)
        @client.send_message('Runtime.evaluate', expression: script)
      end
    end
  end
end
