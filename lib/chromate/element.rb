# frozen_string_literal: true

module Chromate
  class Element
    class NotFoundError < StandardError; end
    class InvalidSelectorError < StandardError; end
    attr_reader :selector, :client, :mouse

    # @param [String] selector
    # @param [Chromate::Client] client
    def initialize(selector, client)
      @selector = selector
      @client   = client
      @object_id, @node_id = find
      @root_id  = document['root']['nodeId']
      @mouse    = Native::MouseController.new(client)
    end

    def inspect
      "#<Chromate::Element:#{selector}>"
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

    private

    # @return [String]
    def find
      @root_id  = document['root']['nodeId']
      result    = client.send_message('DOM.querySelector', nodeId: @root_id, selector: selector)
      raise NotFoundError, "Element not found with selector: #{selector}" unless result&.dig('nodeId')

      node_info = client.send_message('DOM.resolveNode', nodeId: result['nodeId'])
      raise InvalidSelectorError, "Unable to resolve element with selector: #{selector}" unless node_info&.dig('object')

      [node_info['object']['objectId'], result['nodeId']]
    end

    def document
      @document ||= client.send_message('DOM.getDocument')
    end
  end
end
