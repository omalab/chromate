# frozen_string_literal: true

require 'ffi'
require 'chromate/helpers'

module Chromate
  module Hardwares
    module Mouses
      class LinuxController < MouseController
        class InvalidPlatformError < StandardError; end
        include Helpers
        extend FFI::Library

        ffi_lib 'X11'
        ffi_lib 'Xtst'

        # Définition de la structure CGPoint pour Linux
        class CGPoint < FFI::Struct
          layout :x, :int,
                 :y, :int
        end

        attach_function :XOpenDisplay, [:string], :pointer
        attach_function :XCloseDisplay, [:pointer], :int
        attach_function :XDefaultRootWindow, [:pointer], :ulong
        attach_function :XWarpPointer, %i[pointer ulong ulong int int uint uint int int], :int
        attach_function :XFlush, [:pointer], :int
        attach_function :XQueryPointer, %i[pointer ulong pointer pointer pointer pointer pointer pointer pointer], :int
        attach_function :XTestFakeButtonEvent, %i[pointer uint int ulong], :int
        attach_function :XTestFakeMotionEvent, %i[pointer int int int ulong], :int

        LEFT_BUTTON = 1
        RIGHT_BUTTON = 3

        def initialize(element: nil, client: nil)
          raise InvalidPlatformError, 'MouseController is only supported on Linux' unless linux?

          super
          @display = XOpenDisplay(nil)
          raise 'Unable to open X display' if @display.null?

          @root_window = XDefaultRootWindow(@display)
        end

        def hover
          point = convert_coordinates(target_x, target_y)
          XWarpPointer(@display, 0, @root_window, 0, 0, 0, 0, point[:x], point[:y])
          XFlush(@display)
          current_mouse_position
        end

        def click
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

        def current_mouse_position
          root_return = FFI::MemoryPointer.new(:ulong)
          child_return = FFI::MemoryPointer.new(:ulong)
          root_x = FFI::MemoryPointer.new(:int)
          root_y = FFI::MemoryPointer.new(:int)
          win_x = FFI::MemoryPointer.new(:int)
          win_y = FFI::MemoryPointer.new(:int)
          mask_return = FFI::MemoryPointer.new(:uint)

          XQueryPointer(@display, @root_window, root_return, child_return, root_x, root_y, win_x, win_y, mask_return)

          CGPoint.new.tap do |p|
            p[:x] = root_x.read_int
            p[:y] = root_y.read_int
          end
        end

        def convert_coordinates(browser_x, browser_y)
          CGPoint.new.tap do |p|
            p[:x] = browser_x
            p[:y] = browser_y
          end
        end

        def simulate_button_event(button, press)
          XTestFakeButtonEvent(@display, button, press ? 1 : 0, 0)
          XFlush(@display)
        end
      end
    end
  end
end

# Test
# require 'chromate/hardwares/mouses/linux_controller'
# require 'ostruct'
# element = OpenStruct.new(x: 500, y: 300, width: 100, height: 100)
# mouse = Chromate::Hardwares::Mouse::LinuxController.new(element: element)
# mouse.hover
