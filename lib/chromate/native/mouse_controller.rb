# frozen_string_literal: true

module Chromate
  module Native
    class MouseController
      attr_accessor :client

      def initialize(client)
        @client = client
        @mouse_position = { x: 0, y: 0 }
      end

      # Déplacer la souris de manière fluide et précise vers une position (x, y)
      def move_to(x, y, duration: 1.0, steps: 50)
        start_x = @mouse_position[:x]
        start_y = @mouse_position[:y]
        dx = (x - start_x) / steps.to_f
        dy = (y - start_y) / steps.to_f

        steps.times do |step|
          new_x = start_x + (dx * (step + 1))
          new_y = start_y + (dy * (step + 1))
          dispatch_mouse_event('mouseMoved', new_x, new_y)
          sleep(duration / steps)
        end

        # Mise à jour de la position de la souris
        @mouse_position[:x] = x
        @mouse_position[:y] = y
      end

      # Simuler un clic à une position donnée (x, y)
      def click(x, y)
        move_to(x, y, duration: 0.2, steps: 10)
        dispatch_mouse_event('mousePressed', x, y, button: 'left', click_count: 1)
        dispatch_mouse_event('mouseReleased', x, y, button: 'left', click_count: 1)
      end

      private

      # Méthode d'envoi des événements de souris à CDP
      def dispatch_mouse_event(type, x, y, button: 'none', click_count: 0)
        params = {
          type: type,
          x: x,
          y: y,
          button: button,
          clickCount: click_count,
          deltaX: 0,
          deltaY: 0,
          modifiers: 0,
          timestamp: (Time.now.to_f * 1000).to_i
        }

        @client.send_message('Input.dispatchMouseEvent', params)
      end
    end
  end
end
