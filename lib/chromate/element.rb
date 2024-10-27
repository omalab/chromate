# frozen_string_literal: true

module Chromate
  class Element
    class NotFoundError < StandardError; end
    class InvalidSelectorError < StandardError; end
    attr_reader :selector, :client, :id, :mouse

    # @param [String] selector
    # @param [Chromate::Client] client
    def initialize(selector, client)
      @selector = selector
      @client   = client
      @id       = find
      @mouse    = Native::MouseController.new(client)
    end

    def inspect
      "#<Chromate::Element:#{id} selector=#{selector}>"
    end

    # @return [String]
    def html
      return @html if @html

      @html = client.send_message('DOM.getOuterHTML', objectId: @id)
      @html = @html['outerHTML']
    end

    def attributes
      return @attributes if @attributes

      js = <<~JS
        function getAttributes() {
          var el = document.querySelector("#{selector}");
          for (var i = 0, atts = el.attributes, n = atts.length, arr = []; i < n; i++){
              arr.push(atts[i].nodeName);
          }
          return arr
        }
        getAttributes();
      JS

      result = client.send_message('Runtime.evaluate', expression: js)
      object_id = result['result']['objectId']
      result = client.send_message('Runtime.getProperties', objectId: object_id)
      result = result['result'].map { |r| r['value'] }
      @attributes = result
    end

    # @return [Hash]
    def bounding_box
      return @bounding_box if @bounding_box

      result = client.send_message('DOM.getBoxModel', objectId: @id)
      @bounding_box = result['model']
    end

    # @return [Integer]
    def x
      bounding_box['content'][0]
    end

    # @return [Integer]
    def y
      bounding_box['content'][1]
    end

    # @return [Integer]
    def width
      bounding_box['width']
    end

    # @return [Integer]
    def height
      bounding_box['height']
    end

    # @return [self]
    def click
      mouse.click(x + (width / 2), y + (height / 2))

      self
    end

    # @return [self]
    def hover
      mouse.move_to(x + (width / 2), y + (height / 2))

      self
    end

    private

    # @return [String]
    def find
      document  = client.send_message('DOM.getDocument')
      root_id   = document['root']['nodeId']
      result    = client.send_message('DOM.querySelector', nodeId: root_id, selector: selector)
      raise NotFoundError, "Element not found with selector: #{selector}" unless result&.dig('nodeId')

      node_info = client.send_message('DOM.resolveNode', nodeId: result['nodeId'])
      raise InvalidSelectorError, "Unable to resolve element with selector: #{selector}" unless node_info&.dig('object')

      node_info['object']['objectId']
    end
  end
end
