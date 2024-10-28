# frozen_string_literal: true

module Chromate
  class Element
    class NotFoundError < StandardError
      def initialize(selector, root_id)
        super("Element not found with selector: #{selector} under root_id: #{root_id}")
      end
    end

    class InvalidSelectorError < StandardError
      def initialize(selector)
        super("Unable to resolve element with selector: #{selector}")
      end
    end
    attr_reader :selector, :client, :mouse

    # @param [String] selector
    # @param [Chromate::Client] client
    # @option [Integer] node_id
    # @option [String] object_id
    # @option [Integer] root_id
    def initialize(selector, client, node_id: nil, object_id: nil, root_id: nil)
      @selector   = selector
      @client     = client
      @object_id  = object_id
      @node_id    = node_id
      @object_id, @node_id = find(selector, root_id) unless @object_id && @node_id
      @root_id  = root_id || document['root']['nodeId']
      @mouse    = Native::MouseController.new(client)
    end

    def inspect
      value = selector.length > 20 ? "#{selector[0..20]}..." : selector
      "#<Chromate::Element:#{value}>"
    end

    def text
      return @text if @text

      result = client.send_message('Runtime.callFunctionOn', functionDeclaration: 'function() { return this.innerText; }', objectId: @object_id)
      @text = result['result']['value']
    end

    # @return [String]
    def html
      return @html if @html

      @html = client.send_message('DOM.getOuterHTML', objectId: @object_id)
      @html = @html['outerHTML']
    end

    # @return [Hash]
    def attributes
      return @attributes if @attributes

      result = client.send_message('DOM.getAttributes', nodeId: @node_id)
      @attributes = Hash[*result['attributes']]
    end

    def set_attribute(name, value)
      client.send_message('DOM.setAttributeValue', nodeId: @node_id, name: name, value: value)
      dispatch_event('change')
    end

    # @return [Hash]
    def bounding_box
      return @bounding_box if @bounding_box

      result = client.send_message('DOM.getBoxModel', objectId: @object_id)
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

    # @param [String] text
    def type(text)
      client.send_message('Runtime.callFunctionOn', functionDeclaration: "function(value) { this.value = value; this.dispatchEvent(new Event('input')); }",
                                                    objectId: @object_id, arguments: [{ value: text }])

      self
    end

    # @param [String] selector
    # @return [Chromate::Element]
    def find_element(selector)
      find_elements(selector, max: 1).first
    end

    # @param [String] selector
    # @option [Integer] max
    # @return [Array<Chromate::Element>]
    def find_elements(selector, max: 0)
      results = client.send_message('DOM.querySelectorAll', nodeId: @node_id, selector: selector)
      results['nodeIds'].each_with_index.filter_map do |node_id, idx|
        node_info = client.send_message('DOM.resolveNode', nodeId: node_id)
        next unless node_info['object']
        break if max.positive? && idx >= max

        Element.new(selector, client, node_id: node_id, object_id: node_info['object']['objectId'], root_id: @node_id)
      end
    end

    private

    def dispatch_event(event)
      client.send_message('DOM.dispatchEvent', nodeId: @node_id, type: event)
    end

    # @return [Array] [object_id, node_id]
    def find(selector, root_id = nil)
      @root_id  = root_id || document['root']['nodeId']
      result    = client.send_message('DOM.querySelector', nodeId: @root_id, selector: selector)
      raise NotFoundError.new(selector, @root_id) unless result['nodeId']

      node_info = client.send_message('DOM.resolveNode', nodeId: result['nodeId'])
      raise InvalidSelectorError, selector unless node_info['object']

      [node_info['object']['objectId'], result['nodeId']]
    end

    def document
      @document ||= client.send_message('DOM.getDocument')
    end
  end
end
