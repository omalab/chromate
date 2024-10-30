# frozen_string_literal: true

require 'ffi'
require 'chromate/helpers'
module Chromate
  module Hardwares
    module Mouse
      class VirtualController < MouseController
        class InvalidPlatformError < StandardError; end
        include Helpers
        extend FFI::Library

        ffi_lib '/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices'

        class CGPoint < FFI::Struct
          layout :x, :float,
                 :y, :float
        end

        attach_function :CGEventCreateMouseEvent, [:pointer, :uint32, CGPoint.by_value, :uint32], :pointer
        attach_function :CGEventPost, %i[uint32 pointer], :void
        attach_function :CGEventSetType, %i[pointer uint32], :void
        attach_function :CFRelease, [:pointer], :void
        attach_function :CGMainDisplayID, [], :uint32
        attach_function :CGEventCreate, [:pointer], :pointer
        attach_function :CGEventGetLocation, [:pointer], CGPoint.by_value

        LEFT_DOWN   = 1
        LEFT_UP     = 2
        RIGHT_DOWN  = 3
        RIGHT_UP    = 4
        MOUSE_MOVED = 5

        def initialize(element: nil, client: nil)
          raise InvalidPlatformError, 'MouseController is only supported on macOS' unless mac?

          super
          @last_known_position = CGPoint.new
          @last_known_position[:x] = 0.0
          @last_known_position[:y] = 0.0
        end

        def hover
          point = CGPoint.new
          point[:x] = target_x
          point[:y] = target_y
          create_and_post_event(MOUSE_MOVED, point)
          current_mouse_position
        end

        def click
          current_pos = current_mouse_position
          create_and_post_event(LEFT_DOWN, current_pos)
          create_and_post_event(LEFT_UP, current_pos)
        end

        def right_click
          current_pos = current_mouse_position
          create_and_post_event(RIGHT_DOWN, current_pos)
          create_and_post_event(RIGHT_UP, current_pos)
        end

        def double_click
          click
          sleep(rand(DOUBLE_CLICK_DURATION_RANGE))
          click
        end

        private

        def create_and_post_event(event_type, point)
          event = CGEventCreateMouseEvent(nil, event_type, point, 0)
          CGEventPost(0, event)
          CFRelease(event)
        end

        def current_mouse_position
          event = CGEventCreate(nil)
          return @last_known_position if event.null?

          point = CGEventGetLocation(event)

          CFRelease(event)

          @last_known_position[:x] = point[:x]
          @last_known_position[:y] = point[:y]

          @mouse_position = {
            x: point[:x],
            y: point[:y]
          }

          CGPoint.new.tap do |p|
            p[:x] = point[:x]
            p[:y] = point[:y]
          end
        end
      end
    end
  end
end

# Test
# require 'chromate/hardwares/mouses/mouse_controller'
# require 'ostruct'
# element = OpenStruct.new(x: 500, y: 300, width: 100, height: 100)
# mouse = Chromate::Hardwares::Mouse::VirtualController.new(element: element)
# mouse.hover
