# frozen_string_literal: true

require 'chromate/helpers'
require 'open3'

module Chromate
  module Hardwares
    module Mouses
      class LinuxController < MouseController
        class InvalidPlatformError < StandardError; end
        include Helpers

        LEFT_BUTTON = 1
        RIGHT_BUTTON = 3

        def initialize(element: nil, client: nil)
          raise InvalidPlatformError, 'MouseController is only supported on Linux' unless linux?

          super
        end

        def hover
          focus_chrome_window
          binding.irb
          system("xdotool mousemove #{target_x} #{target_y}")
          current_mouse_position
        end

        def click
          hover
          simulate_button_event(LEFT_BUTTON, true)
          simulate_button_event(LEFT_BUTTON, false)
        end

        def right_click
          simulate_button_event(RIGHT_BUTTON, true)
          simulate_button_event(RIGHT_BUTTON, false)
        end

        def double_click
          click
          sleep(rand(DOUBLE_CLICK_DURATION_RANGE))
          click
        end

        private

        def focus_chrome_window
          # Recherche de la fenêtre Chrome avec wmctrl
          chrome_window_id = `wmctrl -lx | grep -i "chrome" | awk '{print $1}'`.strip

          if chrome_window_id.empty?
            puts 'Aucune fenêtre Chrome trouvée'
          else
            # Active la fenêtre Chrome en utilisant wmctrl
            system("wmctrl -ia #{chrome_window_id}")
          end
        end

        def current_mouse_position
          x = nil
          y = nil
          Open3.popen3('xdotool getmouselocation --shell') do |_, stdout, _, _|
            output = stdout.read
            x = output.match(/X=(\d+)/)[1].to_i
            y = output.match(/Y=(\d+)/)[1].to_i
          end

          { x: x, y: y }
        end

        def simulate_button_event(button, press)
          action = press ? 'mousedown' : 'mouseup'
          system("xdotool #{action} #{button}")
        end
      end
    end
  end
end
