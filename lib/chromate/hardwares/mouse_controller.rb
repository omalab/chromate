# frozen_string_literal: true

module Chromate
  module Hardwares
    class MouseController
      CLICK_DURATION_RANGE = (0.01..0.1)
      DOUBLE_CLICK_DURATION_RANGE = (0.1..0.5)

      attr_accessor :element, :client, :mouse_position

      # @param [Chromate::Element] element
      # @param [Chromate::Client] client
      def initialize(element: nil, client: nil)
        @element        = element
        @client         = client
        @mouse_position = { x: 0, y: 0 }
      end

      def hover
        raise NotImplementedError
      end

      def click
        raise NotImplementedError
      end

      def double_click
        raise NotImplementedError
      end

      def right_click
        raise NotImplementedError
      end

      def position_x
        mouse_position[:x]
      end

      def position_y
        mouse_position[:y]
      end

      private

      def target_x
        element.x + (element.width / 2)
      end

      def target_y
        element.y + (element.height / 2)
      end

      def bezier_curve(steps: 50) # rubocop:disable Metrics/AbcSize
        control_x = (target_x / 2)
        control_y = (target_y / 2)

        (0..steps).map do |t|
          t /= steps.to_f
          # Compute the position on the quadratic Bezier curve
          new_x = (((1 - t)**2) * position_x) + (2 * (1 - t) * t * control_x) + ((t**2) * target_x)
          new_y = (((1 - t)**2) * position_y) + (2 * (1 - t) * t * control_y) + ((t**2) * target_y)
          { x: new_x, y: new_y }
        end
      end
    end
  end
end
