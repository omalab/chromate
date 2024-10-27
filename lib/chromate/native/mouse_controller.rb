# frozen_string_literal: true

module Chromate
  module Native
    class MouseController
      attr_accessor :client

      # @attr [Hash] mouse_position
      # @param [Chromate::Client] client
      def initialize(client)
        @client = client
        @mouse_position = { x: 0, y: 0 }
      end

      # @param [Integer] to_x
      # @param [Integer] to_y
      # @option [Float] duration
      # @option [Integer] steps
      def move_to(to_x, to_y, duration: 1.0, steps: 50)
        start_x = @mouse_position[:x]
        start_y = @mouse_position[:y]
        points = bezier_curve(start_x, start_y, to_x, to_y, (to_x / 2), (to_y / 2), steps)

        points.each do |point|
          dispatch_mouse_event('mouseMoved', point[:x], point[:y])
          sleep(duration / steps)
        end

        # Update mouse position
        @mouse_position[:x] = x
        @mouse_position[:y] = y
      end

      # @param to_x [Integer]
      # @param to_y [Integer]
      def click(to_x, to_y)
        steps     = rand(5..18).to_a.sample
        duration  = steps * rand(0.01..0.05)

        move_to(to_x, to_y, duration: duration, steps: steps)
        dispatch_mouse_event('mousePressed', to_x, to_y, button: 'left', click_count: 1)
        sleep(rand(0.01..0.1))
        dispatch_mouse_event('mouseReleased', to_x, to_y, button: 'left', click_count: 1)
      end

      private

      # @param [String] type mouseMoved, mousePressed, mouseReleased
      # @param [Integer] target_x
      # @param [Integer] target_y
      # @option [String] button
      # @option [Integer] click_count
      def dispatch_mouse_event(type, target_x, target_y, button: 'none', click_count: 0)
        params = {
          type: type,
          x: target_x,
          y: target_y,
          button: button,
          clickCount: click_count,
          deltaX: 0,
          deltaY: 0,
          modifiers: 0,
          timestamp: (Time.now.to_f * 1000).to_i
        }

        client.send_message('Input.dispatchMouseEvent', params)
      end

      def bezier_curve(from_x, from_y, to_x, to_y, steps = 50)
        control_x = (to_x / 2)
        control_y = (to_y / 2)

        (0..steps).map do |t|
          t /= steps.to_f
          # Compute the position on the quadratic Bezier curve
          new_x = (((1 - t)**2) * from_x) + (2 * (1 - t) * t * control_x) + ((t**2) * to_x)
          new_y = (((1 - t)**2) * from_y) + (2 * (1 - t) * t * control_y) + ((t**2) * to_y)
          { x: new_x, y: new_y }
        end
      end
    end
  end
end
